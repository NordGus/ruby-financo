# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class FormFor
      def self.account(account)
        attributes = {
          "archived" => account.archived_at.present?,
          "at" => account.history&.debits&.first&.issued_at,
          "amount" => account.history&.debits&.first&.source_amount
        }

        form_for(kind: account.kind, account:, attributes:)
      end

      def self.create(attributes)
        form_for(kind: attributes[:kind], attributes:)
      end

      def self.update(account, attributes: {})
        form_for(kind: account.kind, account:, attributes:)
      end

      def self.form_for(kind:, account: nil, attributes: {})
        case kind
        when *Account.capital_kinds_array
          CapitalForm.new(account:, attributes:)
        when *Account.debt_loan_kinds_array
          Debt::LoanForm.new(account:, attributes:)
        when *Account.debt_credit_line_kinds_array
          Debt::CreditLineForm.new(account:, attributes:)
        when *Account.external_kinds_array
          ExternalForm.new(account:, attributes:)
        else
          raise ArgumentError, "unsupported kind: #{kind}"
        end
      end
    end
  end
end
