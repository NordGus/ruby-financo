# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.uuid :parent_id, null: true, index: { name: :index_account_parent }
      t.string :kind, null: false, index: { name: :index_account_kind }
      t.text :currency, null: false, index: { name: :index_account_currency }
      t.string :name, null: false
      t.text :description
      t.string :color, null: false
      t.bigint :capital, null: false, default: 0
      t.datetime :archived_at, index: { name: :index_account_archived }
      t.datetime :deleted_at, index: { name: :index_account_deleted }

      t.timestamps
    end
  end
end
