require "test_helper"

class AccountsAndGoals::LandingControllerTest < ActionDispatch::IntegrationTest
  test "should get landing" do
    get accounts_and_goals_landing_landing_url
    assert_response :success
  end
end
