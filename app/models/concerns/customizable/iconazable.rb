# frozen_string_literal: true

module Customizable
  # rubocop:disable Metrics/ModuleLength
  module Iconazable
    extend ActiveSupport::Concern

    # TODO(#1): search and list icon theme
    ICONS = {
      bank: 'icon-bank'
    }.freeze

    included do
      validates :icon, presence: true, inclusion: { in: ICONS.keys.map(&:to_s) }
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
