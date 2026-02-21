require "test_helper"

# Geocoder gem testing
# https://github.com/alexreisner/geocoder?tab=readme-ov-file#testing
class GeocodingClientTest < ActiveSupport::TestCase
  setup do
    @client = GeocodingClient.new
    Geocoder.configure(lookup: :test)
  end

  test "returns a Geocode with correct attributes for a valid address" do
    Geocoder::Lookup::Test.add_stub(
      "One Apple Park Way, Cupertino, CA 95014, U.S.A.", [
        { postal_code: "95014", latitude: 12.3456, longitude: -12.3456, city: "Cupertino", state: "California" }
      ]
    )

    geocode = @client.call("One Apple Park Way, Cupertino, CA 95014, U.S.A.")

    assert_instance_of Geocode, geocode
    assert_equal "95014", geocode.zip_code
    assert_equal 12.3456, geocode.latitude
    assert_equal(-12.3456, geocode.longitude)
    assert_equal "Cupertino", geocode.city
    assert_equal "California", geocode.state
  end

  test "raises an error when no geocoding results are found" do
    Geocoder::Lookup::Test.add_stub("TOTALLY_WRONG_ADDRESS", [])

    error = assert_raises(GeocodingClient::Error) do
      @client.call("TOTALLY_WRONG_ADDRESS")
    end

    assert_equal "I'm sorry, please check your address.", error.message
  end

  test "raises an error when the result has a blank postal code" do
    Geocoder::Lookup::Test.add_stub(
      "NO ZIP", [
        { postal_code: "", latitude: 12.3456, longitude: -12.3456, city: "Mountain View", state: "California" }
      ]
    )

    error = assert_raises(GeocodingClient::Error) do
      @client.call("NO ZIP")
    end

    assert_equal "Unable to resolve the zip code. Please try again!", error.message
  end
end
