# frozen_string_literal: true

module DeletableRecord
  extend ActiveSupport::Concern

  included do
    before_create -> { throw(:abort) }
    before_save -> { throw(:abort) unless restore }
    before_update -> { throw(:abort) unless restore }

    attribute :restore, :boolean, default: false

    default_scope -> { where.not(deleted_at: nil) }
  end
end
