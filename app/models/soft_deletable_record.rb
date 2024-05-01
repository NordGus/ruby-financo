# frozen_string_literal: true

class SoftDeletableRecord < ApplicationRecord
  self.abstract_class = true

  def destroy
    transaction do
      run_callbacks :destroy do
        update(deleted_at: Time.current)
      end
    end

    deleted_at.present?
  end

  default_scope -> { where(deleted_at: nil) }
  scope :not_deleted, -> { where(deleted_at: nil) }
end
