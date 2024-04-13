# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :source, class_name: 'Account', foreign_key: 'source_id'
  belongs_to :target, class_name: 'Account', foreign_key: 'target_id'

  validates :target, comparison: { other_than: :source }
  validates :source_amount, presence: true
  validates :target_amount, presence: true
  validate  :amounts_negativity_or_positivity_match
  validates :issued_at, presence: true
  validates :executed_at, comparison: { greater_than_or_equal_to: :issued_at },
                          if: -> { executed_at.present? }

  private

  def amounts_negativity_or_positivity_match
    return if source_amount.negative? == target_amount.negative?

    errors.add(:source_amount, :amount_mismatch, message: 'positivity/negativity mismatch')
    errors.add(:target_amount, :amount_mismatch, message: 'positivity/negativity mismatch')
  end
end
