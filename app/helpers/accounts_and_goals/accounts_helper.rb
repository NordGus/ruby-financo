# frozen_string_literal: true

module AccountsAndGoals
  module AccountsHelper
    def dom_id_for_account(account, preview: false)
      preview ? "#{dom_id(account)}_preview" : dom_id(account)
    end
  end
end
