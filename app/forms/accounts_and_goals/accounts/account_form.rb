# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class AccountForm < FormModel::Base
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

      validates :parent_id, comparison: { other_than: :id }, if: -> { parent_id.present? }
      validates :kind, presence: true, inclusion: { in: Account.visible_kinds_array }
      validates :currency, presence: true, inclusion: { in: Account::CURRENCIES }
      validates :name, presence: true, length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }
      validates :capital, presence: true

      def initialize(account: nil, attributes: {})
        if account.present?
          super(account.attributes.except("created_at", "updated_at").merge(attributes))
        else
          super(attributes)
        end
      end

      def self.model_name
        ActiveModel::Name.new(self, AccountsAndGoals::Accounts, "AccountsAndGoals::Accounts::Account")
      end

      def persisted?
        id.present?
      end
    end
  end
end
