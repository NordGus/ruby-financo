# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class Form
      def self.for_account(account)
        new(kind: account.kind, account:)
      end

      def self.for_params(params)
        new(kind: params[:kind], params:)
      end

      private

      def initialize(kind:, account: nil, params: nil)
        case kind
        when *Account.capital_kinds_array
          CapitalForm.new(account:, params:)
        when *Account.debt_loan_kinds_array
          Debt::LoanForm.new(account:, params:)
        when *Account.debt_credit_line_kinds_array
          Debt::CreditLineForm.new(account:, params:)
        when *Account.external_kinds_array
          ExternalForm.new(account:, params:)
        else
          raise ArgumentError, "unsupported kind: #{kind}"
        end
      end
    end
  end
end
