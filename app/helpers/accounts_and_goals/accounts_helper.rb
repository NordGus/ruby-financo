# frozen_string_literal: true

module AccountsAndGoals
  module AccountsHelper
    def dom_id_for_account(account, preview: false)
      preview ? "#{dom_id(account)}_preview" : dom_id(account)
    end

    def dom_id_for_account_balance(account, preview: false)
      "#{dom_id_for_account(account, preview:)}_balance"
    end

    def dom_id_for_account_payment_progress(account, preview: false)
      "#{dom_id_for_account(account, preview:)}_payment_progress"
    end
  end
end
