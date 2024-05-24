# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class ExternalForm < AccountForm
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

      class Child
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :id, :string
        attribute :name, :string
        attribute :description, :string
        attribute :archived_at, :datetime
        attribute :archived, :boolean, default: false

        attribute :capital, :integer, default: 0

        validates :name,
                  presence: true,
                  length: { minimum: Account::NAME_MIN_LENGTH, maximum: Account::NAME_MAX_LENGTH }

        def persisted?
          id.present?
        end

        def new_record?
          !persisted?
        end
      end
    end
  end
end
