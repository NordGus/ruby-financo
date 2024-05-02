# frozen_string_literal: true

class Account < SoftDeletableRecord
  include Customization::Colorable

  # returns a flat array of all kinds that are visible by the user in the
  # application's UI
  def self.visible_kinds_array
    KINDS.slice(:capital, :debt, :external).values.map(&:values).flatten.compact
  end

  # returns a flat array of all capital accounts kinds that the user can store
  def self.capital_kinds_array
    KINDS[:capital].values.flatten.compact
  end

  # returns a flat array of all debt loan kinds that the user can store
  def self.debt_loan_kinds_array
    KINDS[:debt].slice(:loan, :personal).values.flatten.compact
  end

  # returns a flat array of all debt credit lines kinds that the user can store
  def self.debt_credit_line_kinds_array
    KINDS[:debt].slice(:credit).values.flatten.compact
  end

  # returns a flat array of all external accounts kinds that the user can store
  def self.external_kinds_array
    KINDS[:external].values.flatten.compact
  end

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
      expense: "external.expense"
    }.freeze
  }.freeze

  CURRENCIES = Money::Currency.table.values.map { |currency| currency[:iso_code] }.compact.uniq.freeze
  NAME_MIN_LENGTH = 3
  NAME_MAX_LENGTH = 120

  HISTORY_ACCOUNT_NAME = "System::History"
  HISTORY_ACCOUNT_COLOR = "slate.300"

  belongs_to :parent, class_name: "Account", foreign_key: "parent_id", optional: true
  has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy
  has_one :history,
          -> { where(kind: KINDS[:system][:history]) },
          class_name: "Account",
          foreign_key: "parent_id",
          dependent: :destroy
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

  scope :parents, -> { where(parent_id: nil) }
  scope :visible, -> { where(kind: visible_kinds_array) }
  scope :for_listing, -> { order("archived_at DESC NULLS FIRST") }

  def debt?
    KINDS[:debt].values.flatten.compact.include?(kind)
  end

  def external?
    KINDS[:external].values.flatten.compact.include?(kind)
  end

  def credit_line?
    KINDS[:debt][:credit] == kind
  end

  def balance
    @balance ||= credits.inject(0) { |sum, credit| sum + credit.target_amount } -
                 debits.inject(0) { |sum, debit| sum + debit.source_amount }
  end

  def payment_progress
    return 1 unless debt?

    @payment_progress ||= (balance.to_f + capital) / capital
  end
end
