# frozen_string_literal: true

module FormModel
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    extend ActiveModel::Callbacks

    define_model_callbacks :initialize, only: :after
    define_model_callbacks :save, only: :after

    attribute :form_persistence, :boolean, default: false

    def initialize(*)
      run_callbacks(:initialize) { super(*) }
    end

    def save
      return nil unless valid?

      run_callbacks(:save) do
        ActiveRecord::Base.transaction do
          return yield
        rescue StandardError => e
          Rails.logger.error "failed to save #{self.class}:\n\t#{e.message}\n\t\t#{e.backtrace&.join("\n\t\t")}\n"
          errors.add(
            :form_persistence,
            :failed_to_persist,
            message: "something when wrong while saving #{model_name.element}"
          )

          raise ActiveRecord::Rollback
        end

        nil
      end
    end

    def persisted?
      raise NotImplementedError
    end

    def new_record?
      !persisted?
    end
  end
end
