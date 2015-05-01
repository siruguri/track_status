# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150428224721) do

  create_table "account_entries", force: :cascade do |t|
    t.float    "entry_amount"
    t.string   "merchant_name"
    t.datetime "entry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_entries_tags", force: :cascade do |t|
    t.integer  "transaction_tag_id"
    t.integer  "account_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bin_records", force: :cascade do |t|
    t.string   "number"
    t.string   "brand"
    t.string   "sub_brand"
    t.string   "country_code"
    t.string   "country_name"
    t.string   "bank"
    t.string   "card_type"
    t.string   "card_category"
    t.float    "lat"
    t.float    "long"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_post_redirect_maps", force: :cascade do |t|
    t.integer  "channel_post_id"
    t.integer  "redirect_map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_posts", force: :cascade do |t|
    t.string   "url"
    t.text     "message"
    t.string   "tweet_tags"
    t.string   "short_message"
    t.datetime "last_posted_at"
    t.string   "redirect_url"
    t.integer  "total_post_count"
    t.string   "post_strategy"
    t.boolean  "post_again"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "job_records", force: :cascade do |t|
    t.string   "job_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_name"
  end

  create_table "media_records", force: :cascade do |t|
    t.string   "channel_id"
    t.string   "channel_name"
    t.integer  "channel_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "received_emails", force: :cascade do |t|
    t.string   "source"
    t.text     "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reddit_records", force: :cascade do |t|
    t.string   "username"
    t.text     "user_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "extraction_in_progress"
  end

  create_table "redirect_maps", force: :cascade do |t|
    t.string   "src"
    t.string   "dest"
    t.integer  "redirect_requests_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirect_requests", force: :cascade do |t|
    t.integer  "redirect_map_id"
    t.string   "request_agent"
    t.string   "request_referer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "source"
    t.string   "description"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_tags", force: :cascade do |t|
    t.string   "tag_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "web_articles", force: :cascade do |t|
    t.string   "source"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.string   "original_url"
  end

end
