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
      attribute :amount, :integer
      attribute :at, :date

      # Form specific attributes
      attribute :archived, :boolean, default: false

      # Account validations
      validates :parent_id, comparison: { other_than: :id }, if: -> { parent_id.present? }
      validates :kind, presence: true, inclusion: { in: Account.visible_kinds_array }
      validates :currency, presence: true, inclusion: { in: Account::CURRENCIES }
      validates :name, presence: true, length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }
      validates :capital, presence: true

      # Account history validations
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

      def external?
        Account.external_kinds_array.include?(kind)
      end

      private

      def set_archived
        self.archived = archived_at.present?
      end
    end
  end
end
