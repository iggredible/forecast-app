class ForecastService
  def initialize(
      geocoding_client: GeocodingClient.new,
      weather_client: WeatherClient.new,
      cache: Rails.cache
    )
    @geocoding_client = geocoding_client
    @weather_client = weather_client
    @cache = cache
  end

  def call(address)
    location = geocoding_client.call(address)

    cache_key = "forecast/#{location.zip_code}"
    cached_data = cache.read(cache_key)

    if cached_data
      return build_result(cached_data, location, cached: true)
    else
      weather_data = weather_client.call(location.latitude, location.longitude)
      cache.write(cache_key, weather_data, expires_in: 30.minutes)
      build_result(weather_data, location, cached: false)
    end
  end

  private

  attr_reader :cache, :geocoding_client, :weather_client

  def build_result(weather_data, location, cached:)
    current = weather_data["current"]
    daily = weather_data["daily"]

    extended = daily["time"].each_with_index.map do |date, i|
      {
        date: date,
        high: daily["temperature_2m_max"][i],
        low: daily["temperature_2m_min"][i],
        condition: WeatherClient.condition_for(daily["weather_code"][i])
      }
    end

    Forecast.new(
      current_temp: current["temperature_2m"],
      high: daily["temperature_2m_max"][0],
      low: daily["temperature_2m_min"][0],
      extended_forecast: extended,
      cached: cached,
      zip_code: location.zip_code,
      city: location.city,
      state: location.state
    )
  end
end
