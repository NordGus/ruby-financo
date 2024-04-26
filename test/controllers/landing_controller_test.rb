require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "should get landing" do
    get landing_landing_url
    assert_response :success
  end
end
