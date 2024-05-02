# frozen_string_literal: true

class SoftDeletableRecord < ApplicationRecord
  self.abstract_class = true

  # bad for performance. good for consistency. this is just a prototype
  def destroy
    transaction do
      run_callbacks(:destroy) { update!(deleted_at: Time.current) }
    end

    deleted_at.present?
  end

  default_scope -> { where(deleted_at: nil) }
end
