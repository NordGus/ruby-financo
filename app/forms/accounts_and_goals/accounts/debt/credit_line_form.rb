# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    module Debt
      class CreditLineForm < AccountForm
        attribute :new_capital, :integer, default: 0
        attribute :previous_capital, :integer, default: 0

        validates :capital, numericality: { greater_than: 0 }

        def save
          super do
            set_new_capital
            account = initialize_or_find_account!
            account = memoize_previous_capital(account)
            account = create_or_update_account!(account)
            account = create_or_update_history!(account)
            account = archive_account!(account)
            add_capital_changed_warning
            update_id(account)
          end
        end

        private

        def set_new_capital
          self.new_capital = capital
        end

        def initialize_or_find_account!
          if new_record?
            Account.new(kind: new_capital, currency:, name:, description:, color:, capital:)
          else
            Account.includes(:children, history: [:debits]).where(kind:).find(id)
          end
        end

        def memoize_previous_capital(account)
          self.previous_capital = account.capital
          account
        end

        def create_or_update_account!(account)
          if new_record?
            account.save!
          else
            account.update!(kind: new_capital, currency:, name:, description:, color:, capital:)
          end
          account
        end

        def add_capital_changed_warning
          return if previous_capital == new_capital

          prev_capital = Money.from_cents(previous_capital, currency)
          next_capital = Money.from_cents(new_capital, currency)

          errors.add(
            :form_persistence_warnings,
            :capital_was_changed,
            message: "account capital was changed from #{prev_capital.format} to #{next_capital.format}"
          )
        end
      end
    end
  end
end
