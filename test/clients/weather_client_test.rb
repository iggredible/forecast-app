require "test_helper"
require "webmock/minitest"

class WeatherClientTest < ActiveSupport::TestCase
  setup do
    @client = WeatherClient.new
  end

  test "returns parsed weather data for valid coordinates" do
    response = { "current" => { "temperature_2m" => 72.5 } }.to_json
    url = WeatherClient::BASE_URL

    stub_request(:get, /#{url}/).to_return(body: response)

    result = @client.call(123.4567, -123.4567)
    assert_equal 72.5, result.dig("current", "temperature_2m")
  end

  test ".condition_for for known code returns with value" do
    assert_equal "Clear sky", WeatherClient.condition_for(0)
    assert_equal "Heavy rain", WeatherClient.condition_for(65)
  end

  test ".condition_for for unknown code returns unknown" do
    assert_equal "Unknown", WeatherClient.condition_for(999)
  end
end
