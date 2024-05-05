# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class AccountForm < FormModel::Base
      # Account attributes
      attribute :id, :string
      attribute :parent_id, :string
      attribute :kind, :string
      attribute :currency, :string
      attribute :name, :string
      attribute :description, :string
      attribute :color, :string
      attribute :capital, :integer, default: 0
      attribute :archived_at, :datetime
      attribute :deleted_at, :datetime

      # Account history attributes
      attribute :amount, :integer, default: nil
      attribute :at, :date

      # Form specific attributes
      attribute :personal_loan, :boolean, default: false
      attribute :clear_history, :boolean, default: false
      attribute :archived, :boolean, default: false

      # Account validations
      validates :parent_id, comparison: { other_than: :id }, if: -> { parent_id.present? }
      validates :kind, presence: true, inclusion: { in: Account.visible_kinds_array }
      validates :currency, presence: true, inclusion: { in: Account::CURRENCIES }
      validates :name, presence: true, length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }
      validates :capital, presence: true

      # Account history validations
      validates :at, presence: true, if: -> { amount.present? }
      validates :at, comparison: { less_than_or_equal_to: Time.zone.today }, if: -> { at.present? }

      def initialize(account: nil, attributes: {})
        if account.present?
          super(account.attributes.except("created_at", "updated_at").merge(attributes))
        else
          super(attributes)
        end
      end

      def self.model_name
        ActiveModel::Name.new(self, AccountsAndGoals, "Account")
      end

      def persisted?
        id.present?
      end

      def capital_account?
        @capital_account ||= Account.capital_kinds_array.include?(kind)
      end

      def external_account?
        @external_account ||= Account.external_kinds_array.include?(kind)
      end

      def loan_account?
        @loan_account ||= Account.debt_loan_kinds_array.include?(kind)
      end

      def credit_line_account?
        @credit_line_account ||= Account.debt_credit_line_kinds_array.include?(kind)
      end

      protected

      def archive_account!(account)
        return account if archived_at.present? == archived

        self.archived_at = archived ? Time.current : archived

        account.children.update_all(archived_at:, updated_at: Time.current)
        account.update!(archived_at:)

        account
      end

      def create_or_update_history!(account)
        history = account.history || account.create_history!(
          name: Account::HISTORY_ACCOUNT_NAME,
          kind: Account::KINDS[:system][:history],
          currency:,
          color: Account::HISTORY_ACCOUNT_COLOR,
          capital: 0
        )

        update_history_currency!(history)

        if clear_history
          clear_history_debit!(history)
        elsif amount.present?
          update_or_create_history_debit!(history)
        end

        account
      end

      def update_history_currency!(history)
        history.update!(currency:) unless currency == history.currency
      end

      def clear_history_debit!(history)
        history.debits&.first&.destroy! unless new_record?
      end

      def update_or_create_history_debit!(history)
        debit = history.debits.first || history.debits.build(
          target_id: history.parent_id,
          issued_at: at,
          executed_at: at,
          source_amount: amount,
          target_amount: amount
        )

        if debit.new_record?
          debit.save!
        elsif history_debit_params(debit).present?
          debit.update!(history_debit_params(debit))
        end
      end

      def history_debit_params(debit)
        @history_debit_params ||= begin
          params = { issued_at: at, executed_at: at, source_amount: amount, target_amount: amount }
          params.reject! { |attr| params[attr] == debit.issued_at }
          params.reject! { |attr| params[attr] == debit.source_amount }
          params
        end
      end

      def update_id(account)
        self.id = account.id if new_record?

        account
      end
    end
  end
end
