# frozen_string_literal: true

module SoftDeletableRecord
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(deleted_at: nil) }
  end

  private_instance_methods :_raise_record_not_destroyed

  def destroy
    transaction do
      run_callbacks(:destroy) { update!(deleted_at: Time.current) }
    end

    deleted_at.present?
  end

  def destroy!
    destroy || _raise_record_not_destroyed
  end

  def delete_all
    update_all(deleted_at: Time.current, updated_at: Time.current)
  end

  def _raise_record_not_destroyed
    raise ActiveRecord::RecordNotDestroyed, "Failed to destroy record #{self.class} with id #{id}"
  end
end
