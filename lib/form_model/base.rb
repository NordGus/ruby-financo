# frozen_string_literal: true

module FormModel
  class Base
    include ActiveModel::Model
    extend ActiveModel::Callbacks
    include ActiveModel::Attributes

    define_model_callbacks :initialize, only: :after

    def initialize(*)
      run_callbacks :initialize do
        super(*)
      end
    end

    def persisted?
      raise NotImplementedError
    end
  end
end
