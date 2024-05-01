# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def soft_delete
    raise NotImplementedError
  end
end
