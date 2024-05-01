# frozen_string_literal: true

module Deletable
  class Account < DeletableRecord
    self.table_name = ::Account.table_name

    has_many :children, class_name: "Deletable::Account", foreign_key: "parent_id", dependent: :destroy
    has_many :debits,
             class_name: "Deletable::Transaction",
             foreign_key: "source_id",
             dependent: :destroy,
             inverse_of: :source
    has_many :credits,
             class_name: "Deletable::Transaction",
             foreign_key: "target_id",
             dependent: :destroy,
             inverse_of: :target

    def restore
      now = Time.current

      transaction do
        debits.update_all(deleted_at: nil, updated_at: now)
        credits.update_all(deleted_at: nil, updated_at: now)
        children.update_all(deleted_at: nil, updated_at: now)
        update!(deleted_at: nil)
      end

      deleted_at.nil?
    end
  end
end
