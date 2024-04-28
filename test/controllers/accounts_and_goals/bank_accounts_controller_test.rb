require "test_helper"

class AccountsAndGoals::BankAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get accounts_and_goals_bank_accounts_index_url
    assert_response :success
  end

  test "should get show" do
    get accounts_and_goals_bank_accounts_show_url
    assert_response :success
  end

  test "should get new" do
    get accounts_and_goals_bank_accounts_new_url
    assert_response :success
  end

  test "should get create" do
    get accounts_and_goals_bank_accounts_create_url
    assert_response :success
  end

  test "should get update" do
    get accounts_and_goals_bank_accounts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get accounts_and_goals_bank_accounts_destroy_url
    assert_response :success
  end

  test "should get balance" do
    get accounts_and_goals_bank_accounts_balance_url
    assert_response :success
  end
end
