# frozen_string_literal: true

class DeletableRecord < ApplicationRecord
  self.abstract_class = true

  before_create -> { throw(:abort) }
  before_save -> { throw(:abort) }
  before_update -> { throw(:abort) }

  default_scope -> { where.not(deleted_at: nil) }
end
