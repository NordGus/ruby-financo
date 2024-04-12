# frozen_string_literal: true

class Account < ApplicationRecord
  KINDS = {
    system: {
      history: 'system.history'
    }.freeze,
    capital: {
      normal: 'capital.normal',
      savings: 'capital.savings'
    }.freeze,
    external: {
      income: 'external.income',
      external: 'external.debt'
    }.freeze
  }.freeze

  CURRENCIES = {
    USD: 'USD',
    GBP: 'GBP',
    EUR: 'EUR'
  }.freeze

  NAME_MIN_LENGTH = 3
  NAME_MAX_LENGTH = 120

  belongs_to :parent, class_name: 'Account', foreign_key: 'parent_id', optional: true
  has_many :children, class_name: 'Account', foreign_key: 'parent_id', dependent: :destroy

  validates :kind, presence: true, inclusion: { in: KINDS.values.map(&:values).flatten.compact }
  validates :currency, presence: true, inclusion: { in: CURRENCIES.values }
  validates :name, presence: true, length: { minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH }
  validates :color, presence: true
  validates :icon, presence: true
  validates :capital, presence: true

  default_scope -> { where(deleted_at: nil) }
end
