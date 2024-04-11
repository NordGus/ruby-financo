# frozen_string_literal: true

class Account < ApplicationRecord
  SYSTEM_KINDS = %w[system.history].freeze
  CAPITAL_KINDS = %w[capital.normal capital.savings].freeze
  DEBT_KINDS = %w[debt.loan debt.credit].freeze
  EXTERNAL_KINDS = %w[external.income external.expense].freeze
  KINDS = (SYSTEM_KINDS + CAPITAL_KINDS + DEBT_KINDS + EXTERNAL_KINDS).freeze

  CURRENCIES = %w[USD GBP EUR].freeze

  NAME_MIN_LENGTH = 3
  NAME_MAX_LENGTH = 120

  belongs_to :parent, class_name: 'Account', foreign_key: 'parent_id', optional: true
  has_many :children, class_name: 'Account', foreign_key: 'parent_id', dependent: :destroy

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :name, presence: true
  validates :name, length: { minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH }
  validates :color, presence: true
  validates :icon, presence: true
  validates :capital, presence: true

  default_scope -> { where(deleted_at: nil) }
end
