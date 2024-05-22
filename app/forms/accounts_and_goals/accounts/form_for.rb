# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class FormFor
      def self.account(account)
        attributes = {
          "archived" => account.archived_at.present?,
          "at" => account.history&.debits&.first&.issued_at,
          "amount" => account.history&.debits&.first&.source_amount,
          "personal_loan" => account.personal_loan?,
          "children_attributes" => map_account_children(account)
        }

        form_for(kind: account.kind, account:, attributes: attributes.compact)
      end

      def self.create(attributes)
        form_for(kind: attributes[:kind], attributes:)
      end

      def self.update(account, attributes: {})
        form_for(kind: account.kind, account:, attributes:)
      end

      class << self
        private

        def form_for(kind:, account: nil, attributes: {})
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

        def map_account_children(account)
          return nil unless account.external?

          Hash[account.children.map.with_index do |child, idx|
            [
              idx.to_s,
              child.attributes
                   .slice("id", "name", "description", "archived_at")
                   .merge("archived" => child.archived_at.present?)
            ]
          end]
        end
      end
    end
  end
end
