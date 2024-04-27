require "test_helper"

class AccountsAndGoals::SummaryControllerTest < ActionDispatch::IntegrationTest
  test "should get capital" do
    get accounts_and_goals_summary_capital_url
    assert_response :success
  end

  test "should get debt" do
    get accounts_and_goals_summary_debt_url
    assert_response :success
  end

  test "should get total" do
    get accounts_and_goals_summary_total_url
    assert_response :success
  end

  test "should get account" do
    get accounts_and_goals_summary_account_url
    assert_response :success
  end
end
