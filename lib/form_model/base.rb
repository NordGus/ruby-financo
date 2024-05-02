# frozen_string_literal: true

module FormModel
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    extend ActiveModel::Callbacks

    define_model_callbacks :initialize, only: :after

    def initialize(*)
      run_callbacks(:initialize) { super(*) }
    end

    def persisted?
      raise NotImplementedError
    end

    def new_record?
      !persisted?
    end
  end
end
