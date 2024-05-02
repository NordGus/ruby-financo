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
      attribute :archived, :boolean, default: false
      attribute :persistence, :boolean, default: false

      # Account validations
      validates :parent_id, comparison: { other_than: :id }, if: -> { parent_id.present? }
      validates :kind, presence: true, inclusion: { in: Account.visible_kinds_array }
      validates :currency, presence: true, inclusion: { in: Account::CURRENCIES }
      validates :name, presence: true, length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }
      validates :capital, presence: true

      # Account history validations
      validates :at, presence: true, if: -> { amount.present? }
      validates :at, comparison: { less_than_or_equal_to: Time.zone.today }, if: -> { at.present? }

      after_initialize :set_archived

      def initialize(account: nil, attributes: {})
        if account.present?
          super(account.attributes.except("created_at", "updated_at").merge(attributes).with_indifferent_access)
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

      def save
        return nil unless valid?

        ActiveRecord::Base.transaction do
          return yield
        rescue StandardError => e
          logger.error "failed to save #{self.class}:\n\t#{e.message}\n\t\t#{e.backtrace&.join("\n\t\t")}\n"
          errors.add(:persistence, :failed_to_persist)
          set_archived
          raise ActiveRecord::Rollback
        end
      end

      def external?
        Account.external_kinds_array.include?(kind)
      end

      protected

      def archive_account!(account)
        return account unless persisted?

        self.archived_at = Time.current

        account.transaction do
          account.children.update_all(archived_at:, updated_at: archived_at)
          account.update!(archived_at:)
        end

        if account.archived_at.nil?
          self.archived_at = nil
          raise ActiveRecord::Rollback, "failed to archived Account #{account.id}"
        end

        account
      end

      def create_or_update_history!(account)
        history = account.history || account.create_history!(
          name: Account::HISTORY_ACCOUNT_NAME,
          kind: Account::KINDS[:system][:history],
          currency:,
          color: Account::COLORS[:slate][300],
          capital: 0
        )

        update_history_currency!(history)
        update_or_create_history_debit!(history) unless amount.present?

        account
      end

      def update_history_currency!(history)
        history.update!(currency:) unless currency == history.currency
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
        else
          debit.update!(issued_at: at, executed_at: at, source_amount: amount, target_amount: amount)
        end
      end

      def update_id(account)
        self.id = account.id if new_record?

        account
      end

      private

      def set_archived
        self.archived = archived_at.present?
      end
    end
  end
end
