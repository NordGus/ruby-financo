# frozen_string_literal: true

module Deletable
  class Account < ApplicationRecord
    include DeletableRecord

    self.table_name = ::Account.table_name

    has_many :children, class_name: "Deletable::Account", foreign_key: "parent_id", dependent: :destroy
    has_many :debits,
             class_name: "Deletable::Transaction",
             dependent: :destroy,
             inverse_of: :source
    has_many :credits,
             class_name: "Deletable::Transaction",
             dependent: :destroy,
             inverse_of: :target
  end
end
