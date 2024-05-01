# frozen_string_literal: true

module FormModel
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes

    def persisted?
      raise NotImplementedError
    end
  end
end
