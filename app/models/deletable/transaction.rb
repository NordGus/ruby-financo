# frozen_string_literal: true

module Deletable
  class Transaction < ApplicationRecord
    include DeletableRecord

    self.table_name = ::Transaction.table_name

    belongs_to :source, class_name: "Deletable::Account", foreign_key: "source_id", inverse_of: :debits
    belongs_to :target, class_name: "Deletable::Account", foreign_key: "target_id", inverse_of: :credits

    def restore
      transaction do
        update!(deleted_at: nil)
      end

      deleted_at.nil?
    end
  end
end
