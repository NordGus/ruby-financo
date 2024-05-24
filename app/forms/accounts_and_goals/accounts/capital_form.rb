# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class CapitalForm < AccountForm
      def save
        super do
          account = initialize_or_find_account!
          account = create_or_update_account!(account)
          account = create_or_update_history!(account)
          account = archive_account!(account)
          update_id(account)
        end
      end

      private

      def initialize_or_find_account!
        if new_record?
          Account.new(kind:, currency:, name:, description:, color:, capital: 0)
        else
          Account.includes(:children, history: [:debits]).where(kind:).find(id)
        end
      end

      def create_or_update_account!(account)
        new_record? ? account.save! : account.update!(kind:, currency:, name:, description:, color:)
        account
      end
    end
  end
end
