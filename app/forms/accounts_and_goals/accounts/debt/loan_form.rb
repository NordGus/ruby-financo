# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    module Debt
      class LoanForm < AccountForm
        attribute :kind_was_changed, :boolean, default: false
        attribute :new_kind, :string, default: Account::KINDS[:debt][:loan]
        attribute :previous_kind, :string, default: Account::KINDS[:debt][:loan]

        after_initialize :set_personal_loan
        after_initialize :set_new_kind

        def save
          super do
            account = find_or_initialize_account!
            account = memoize_previous_kind(account)
            account = update_or_create_account!(account)
            account = create_or_update_history!(account)
            account = archive_account!(account)

            add_kind_changed_warning unless previous_kind == account.kind
            update_id(account)
          end
        end

        private

        def set_personal_loan
          self.personal_loan = kind == Account::KINDS[:debt][:personal] unless personal_loan
        end

        def set_new_kind
          self.new_kind = Account::KINDS[:debt][:personal] if personal_loan
        end

        def find_or_initialize_account!
          if new_record?
            Account.new(kind: new_kind, currency:, name:, description:, color:, capital:)
          else
            Account.includes(:children, history: [:debits]).where(kind:).find(id)
          end
        end

        def memoize_previous_kind(account)
          self.previous_kind = account.kind

          account
        end

        def update_or_create_account!(account)
          if new_record?
            account.save!
          else
            account.update!(kind: new_kind, currency:, name:, description:, capital:)
          end

          account
        end

        def add_kind_changed_warning
          errors.add(
            :form_persistence_warnings,
            :kind_was_changed,
            messages: "account kind was changed from #{previous_kind} to #{new_kind}"
          )
        end
      end
    end
  end
end
