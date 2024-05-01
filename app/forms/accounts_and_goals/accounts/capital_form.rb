# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    class CapitalForm < AccountForm
      attribute :amount, :integer
      attribute :at, :date

      validates :at, comparison: { less_than_or_equal_to: Time.zone.today }, if: -> { at.present? }
    end
  end
end
