class WeatherClient
  class Error < StandardError; end
  BASE_URL = "https://api.open-meteo.com/v1/forecast"

  # Full list: https://open-meteo.com/en/docs#weathervariables
  # Code	Description
  # 0	Clear sky
  # 1, 2, 3	Mainly clear, partly cloudy, and overcast
  # 45, 48	Fog and depositing rime fog
  # 51, 53, 55	Drizzle: Light, moderate, and dense intensity
  # 56, 57	Freezing Drizzle: Light and dense intensity
  # 61, 63, 65	Rain: Slight, moderate and heavy intensity
  # 66, 67	Freezing Rain: Light and heavy intensity
  # 71, 73, 75	Snow fall: Slight, moderate, and heavy intensity
  # 77	Snow grains
  # 80, 81, 82	Rain showers: Slight, moderate, and violent
  # 85, 86	Snow showers slight and heavy
  # 95 *	Thunderstorm: Slight or moderate
  # 96, 99 *	Thunderstorm with slight and heavy hail
  WEATHER_CODES = {
    0 => "Clear sky",
    1 => "Mainly clear",
    2 => "Partly cloudy",
    3 => "Overcast",
    45 => "Foggy",
    48 => "Depositing rime fog",
    51 => "Light drizzle",
    53 => "Moderate drizzle",
    55 => "Dense drizzle",
    56 => "Light freezing drizzle",
    57 => "Dense freezing drizzle",
    61 => "Slight rain",
    63 => "Moderate rain",
    65 => "Heavy rain",
    66 => "Light freezing rain",
    67 => "Heavy freezing rain",
    71 => "Slight snow",
    73 => "Moderate snow",
    75 => "Heavy snow",
    77 => "Snow grains",
    80 => "Slight rain showers",
    81 => "Moderate rain showers",
    82 => "Violent rain showers",
    85 => "Slight snow showers",
    86 => "Heavy snow showers",
    95 => "Thunderstorm",
    96 => "Thunderstorm with slight hail",
    99 => "Thunderstorm with heavy hail"
  }.freeze

  def self.condition_for(code)
    WEATHER_CODES.fetch(code, "Unknown")
  end

  def call(latitude, longitude)
    uri = build_uri(latitude, longitude)
    response = fetch(uri)

    JSON.parse(response.body)
  rescue StandardError
    raise Error, "Weather data is temporarily unavailable. Please try again."
  end

  private

  def build_uri(latitude, longitude)
    params = {
      latitude: latitude,
      longitude: longitude,
      current: "temperature_2m",
      daily: "temperature_2m_max,temperature_2m_min,weather_code",
      temperature_unit: "fahrenheit",
      wind_speed_unit: "mph",
      timezone: "auto",
      forecast_days: 7
    }

    URI.parse("#{BASE_URL}?#{URI.encode_www_form(params)}")
  end

  def fetch(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    http.get(uri.request_uri)
  end
end
