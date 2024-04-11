# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_11_192142) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_id"
    t.string "kind", null: false
    t.text "currency", null: false
    t.string "name", null: false
    t.text "description"
    t.string "color", null: false
    t.string "icon", null: false
    t.decimal "capital", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_account_archived"
    t.index ["currency"], name: "index_account_currency"
    t.index ["deleted_at"], name: "index_account_deleted"
    t.index ["kind"], name: "index_account_kind"
    t.index ["parent_id"], name: "index_account_parent"
  end

end
