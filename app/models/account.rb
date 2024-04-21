# frozen_string_literal: true

class Account < ApplicationRecord
  include Customization::Colorable
  include Customization::Iconazable

  KINDS = {
    system: {
      history: "system.history"
    }.freeze,
    capital: {
      normal: "capital.normal",
      savings: "capital.savings"
    }.freeze,
    debt: {
      personal: "debt.personal",
      loan: "debt.loan",
      credit: "debt.credit"
    }.freeze,
    external: {
      income: "external.income",
      external: "external.debt"
    }.freeze
  }.freeze

  CURRENCIES = Money::Currency.table.values.map { |currency| currency[:iso_code] }.compact.uniq.freeze
  NAME_MIN_LENGTH = 3
  NAME_MAX_LENGTH = 120

  belongs_to :parent, class_name: "Account", foreign_key: "parent_id", optional: true
  has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy
  has_many :debits,
           -> { order(issued_at: :desc) },
           class_name: "Transaction",
           foreign_key: "source_id",
           dependent: :destroy,
           inverse_of: :source
  has_many :credits,
           -> { order("executed_at DESC NULLS FIRST") },
           class_name: "Transaction",
           foreign_key: "target_id",
           dependent: :destroy,
           inverse_of: :target

  validates :parent_id, comparison: { other_than: :id }, if: -> { parent_id.present? }
  validates :kind, presence: true, inclusion: { in: KINDS.values.map(&:values).flatten.compact }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :name, presence: true, length: { minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH }
  validates :capital, presence: true

  default_scope -> { where(deleted_at: nil) }
end
