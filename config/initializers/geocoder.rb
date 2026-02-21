# Use google first. Nominatim can get temperamental and block you.
config = {
  user_agent: "weather-forecast-app",
  timeout: 5,
  units: :mi
}
if ENV['GOOGLE_GEOCODING_API_KEY']
  config[:lookup] = :google
  config[:api_key] = ENV['GOOGLE_GEOCODING_API_KEY']
else
  config[:lookup] = :nominatim
end

Geocoder.configure(config)
