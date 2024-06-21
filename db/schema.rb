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

ActiveRecord::Schema[7.1].define(version: 2024_06_21_224755) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentication_tokens", force: :cascade do |t|
    t.string "token"
    t.bigint "user_id"
    t.datetime "expires_at"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "from_currency"
    t.string "to_currency"
    t.decimal "from_amount", precision: 10, scale: 5
    t.decimal "to_amount", precision: 10, scale: 3
    t.string "status"
    t.string "receipient_email"
    t.string "sender_email"
    t.string "payment_address"
    t.string "public_id"
    t.string "network"
    t.jsonb "account_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deposit_confirmed_at"
    t.datetime "payout_confirmed_at"
    t.string "payout_reference"
    t.datetime "failed_at"
    t.jsonb "metadata"
    t.jsonb "failure_reason"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified"
  end

  create_table "wallet_addresses", force: :cascade do |t|
    t.string "network"
    t.string "address"
    t.string "address_id"
    t.string "currency"
    t.datetime "last_used_at"
    t.boolean "in_use", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authentication_tokens", "users"
end
