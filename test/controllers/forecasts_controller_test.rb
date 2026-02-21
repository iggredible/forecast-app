require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "index returns 200" do
    get root_path

    assert_response :ok
  end

  test "show when given a valid address returns forecast" do
    # get show_forecasts_path, params: { address: "One Apple Park Way, Cupertino, CA 95014, U.S.A." }
    # TODO: need to stub the forecast
    # Stub the forecast here somehow
    # run the show_forecasts_path
    # Check that forecast is valid

    # assert_response :ok
  end

  test "show with blank address redirects with alert" do
    get show_forecasts_path, params: { address: "" }

    assert_redirected_to root_path
    assert_equal "Please enter an address.", flash[:alert]
  end
end
