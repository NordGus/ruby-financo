# frozen_string_literal: true

module AccountsAndGoals
  module BankAccountsHelper
    def dom_id_for_bank_account(account, preview: false)
      preview ? "#{dom_id(account)}_balance_preview" : "#{dom_id(account)}_balance"
    end
  end
end
