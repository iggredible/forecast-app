class GeocodingClient
  class Error < StandardError; end

  def call(address)
    results = Geocoder.search(address)

    if results.empty?
      raise Error, "I'm sorry, please check your address."
    end

    result = results.first

    if result.postal_code.blank?
      raise Error, "Unable to resolve the zip code. Please try again!"
    end

    Geocode.new(
      zip_code: result.postal_code,
      latitude: result.latitude,
      longitude: result.longitude,
      city: result.city,
      state: result.state
    )
  rescue Error
    raise
  rescue StandardError
    raise Error, "Forecast is not working right now. Please try again!"
  end
end
