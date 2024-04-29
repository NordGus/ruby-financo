# frozen_string_literal: true

module Customization
  # rubocop:disable Metrics/ModuleLength
  module Colorable
    extend ActiveSupport::Concern

    COLORS = {
      slate: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      gray: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      zinc: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      neutral: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      stone: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      red: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      orange: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      amber: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      yellow: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      lime: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      green: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      emerald: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      teal: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      cyan: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      sky: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      blue: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      indigo: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      violet: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      purple: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      fuchsia: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      pink: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      },
      rose: {
        100 => {},
        300 => {},
        500 => {},
        700 => {},
        900 => {}
      }
    }.freeze

    included do
      validates :color, presence: true, inclusion: { in: color_options }
    end

    module ClassMethods
      protected

      def color_options
        COLORS.map do |color, groups|
          groups.keys.map { |group| "#{color}.#{group}" }
        end.flatten.compact
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
