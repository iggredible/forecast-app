require "test_helper"

class ForecastServiceTest < ActiveSupport::TestCase
  setup do
    @location = Geocode.new(
      zip_code: "95014",
      latitude: 37.3349,
      longitude: -122.0090,
      city: "Cupertino",
      state: "California"
    )

    @weather_data = {
      "current" => { "temperature_2m" => 99.9 },
      "daily" => {
        "time" => [ "2026-02-20", "2026-02-21", "2026-02-22" ],
        "temperature_2m_max" => [ 110.0, 78.0, 80.0 ],
        "temperature_2m_min" => [ 32.0, 57.0, 58.0 ],
        "weather_code" => [ 0, 2, 61 ]
      }
    }

    @geocoding_client = ->(_address) { @location }
    @weather_client = ->(_lat, _lon) { @weather_data }
    @cache = ActiveSupport::Cache::MemoryStore.new
  end

  test "returns a current day forecast" do
    service = build_service

    forecast = service.call("One Apple Park Way, Cupertino, CA 95014, U.S.A.")

    assert_instance_of Forecast, forecast
    assert_equal 99.9, forecast.current_temp
    assert_equal 110.0, forecast.high
    assert_equal 32.0, forecast.low
    assert_equal "Cupertino", forecast.city
    assert_equal "California", forecast.state
    assert_equal "95014", forecast.zip_code
    assert_equal false, forecast.cached
  end

  test "returns an exttended forecast" do
    service = build_service

    forecast = service.call("Mountain View, CA")

    assert_equal 3, forecast.extended_forecast.length

    first = forecast.extended_forecast[0]
    assert_equal "2026-02-20", first[:date]
    assert_equal 110.0, first[:high]
    assert_equal 32.0, first[:low]
    assert_equal "Clear sky", first[:condition]

    last = forecast.extended_forecast[2]
    assert_equal "2026-02-22", last[:date]
    assert_equal 80.0, last[:high]
    assert_equal 58.0, last[:low]
    assert_equal "Slight rain", last[:condition]
  end

  test "returns cached forecast when called twice" do
    service = build_service

    service.call("Mountain View, CA")
    second_call = service.call("Mountain View, CA")

    assert_equal true, second_call.cached
  end

  test "caches weather data by zip code" do
    service = build_service

    service.call("Mountain View, CA")

    cached = @cache.read("forecast/95014")
    assert_equal @weather_data, cached
  end

  private

  def build_service(weather_client: @weather_client, geocoding_client: @geocoding_client, cache: @cache)
    ForecastService.new(geocoding_client: geocoding_client, weather_client: weather_client, cache: cache)
  end
end
