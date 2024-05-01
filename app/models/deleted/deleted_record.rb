# frozen_string_literal: true

module Deleted
  class DeletedRecord < ApplicationRecord
    default_scope -> { where.not(deleted_at: nil) }
  end
end
