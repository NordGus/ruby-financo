# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class ExternalForm < AccountForm
      class Child
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :id, :string
        attribute :name, :string
        attribute :description, :string
        attribute :archived_at, :datetime
        attribute :archived, :boolean, default: false

        validates :name,
                  presence: true,
                  length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }

        def persisted?
          id.present?
        end

        def new_record?
          !persisted?
        end

        def save!(parent_account)
          account = initialize_or_find_account!(parent_account)
          account = create_or_update_account!(parent_account, account)
          account.id
        end

        private

        def initialize_or_find_account!(parent_account)
          if new_record?
            parent_account.children.build(
              kind: parent_account.kind,
              currency: parent_account.currency,
              color: parent_account.color,
              name:,
              description:,
              capital: 0
            )
          else
            parent_account.children.find(id)
          end
        end

        def create_or_update_account!(parent_account, account)
          if new_record?
            account.save!
          else
            account.update!(
              kind: parent_account.kind,
              currency: parent_account.currency,
              color: parent_account.color,
              name:,
              description:
            )
          end

          account
        end
      end

      attr_accessor :children

      def initialize(account: nil, attributes: nil)
        self.children = []
        super
      end

      def children_attributes=(attributes)
        attributes.each_value do |child_attributes|
          @children << Child.new(child_attributes)
        end
      end

      def save
        super do
          children.each { |child| raise ActiveRecord::RecordInvalid, "invalid child" unless child.valid? }

          account = initialize_or_find_account!
          account = create_or_update_account!(account)
          account, children_ids = create_or_update_children!(account)
          account = archive_account!(account)
          update_id(account, children_ids)
        end
      end

      private

      def initialize_or_find_account!
        if new_record?
          Account.new(kind:, currency:, name:, description:, color:, capital: 0)
        else
          Account.includes(:children).where(kind:).find(id)
        end
      end

      def create_or_update_account!(account)
        new_record? ? account.save! : account.update!(currency:, name:, description:, color:)
        account
      end

      def create_or_update_children!(account)
        [account, children.map { |child| child.save!(account) }]
      end

      def update_id(account, children_ids)
        children.each_with_index { |child, idx| child.id = children_ids[idx] }

        super(account)
      end
    end
  end
end
