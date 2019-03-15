# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_15_034357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_entries", id: :serial, force: :cascade do |t|
    t.float "entry_amount"
    t.string "merchant_name"
    t.datetime "entry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_entries_tags", id: :serial, force: :cascade do |t|
    t.integer "transaction_tag_id"
    t.integer "account_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_taggings", id: :serial, force: :cascade do |t|
    t.integer "article_tag_id"
    t.integer "web_article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_tags", id: :serial, force: :cascade do |t|
    t.string "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bin_records", id: :serial, force: :cascade do |t|
    t.string "number"
    t.string "brand"
    t.string "sub_brand"
    t.string "country_code"
    t.string "country_name"
    t.string "bank"
    t.string "card_type"
    t.string "card_category"
    t.float "lat"
    t.float "long"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configs", id: :serial, force: :cascade do |t|
    t.string "config_key"
    t.text "config_value"
    t.string "config_value_type"
  end

  create_table "document_universes", id: :serial, force: :cascade do |t|
    t.text "universe"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_records", id: :serial, force: :cascade do |t|
    t.string "job_id"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "job_name"
  end

  create_table "oauth_token_hashes", id: :serial, force: :cascade do |t|
    t.string "source"
    t.string "token"
    t.string "secret"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "request_token"
  end

  create_table "received_emails", id: :serial, force: :cascade do |t|
    t.string "source"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "to_address"
    t.index ["to_address"], name: "index_to_address_on_received_emails"
  end

  create_table "reddit_records", id: :serial, force: :cascade do |t|
    t.string "username"
    t.text "user_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "extraction_in_progress"
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.string "source"
    t.string "description"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_tags", id: :serial, force: :cascade do |t|
    t.string "tag_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "unconfirmed_email"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_articles", id: :serial, force: :cascade do |t|
    t.string "source"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "author"
    t.string "original_url"
    t.boolean "fetch_failed"
    t.index ["original_url"], name: "index_original_url_on_web_articles", unique: true
  end

end
