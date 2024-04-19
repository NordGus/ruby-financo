# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :transactions, id: :uuid do |t|
      t.belongs_to :source,
                   null: false,
                   foreign_key: {
                     to_table: :accounts,
                     name: :transaction_source_account_reference
                   },
                   index: { name: :transaction_source_account_reference },
                   type: :uuid
      t.belongs_to :target,
                   null: false,
                   foreign_key: {
                     to_table: :accounts,
                     name: :transaction_target_account_reference
                   },
                   index: { name: :transaction_target_account_reference },
                   type: :uuid
      t.bigint :source_amount, null: false, default: 0
      t.bigint :target_amount, null: false, default: 0
      t.text :notes
      t.date :issued_at, null: false, index: { name: :index_transaction_issued }
      t.date :executed_at, index: { name: :index_transaction_executed }
      t.datetime :deleted_at, index: { name: :index_transaction_deleted }

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
