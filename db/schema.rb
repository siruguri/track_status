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

ActiveRecord::Schema.define(version: 20151104010527) do

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

  create_table "article_taggings", force: :cascade do |t|
    t.integer  "article_tag_id"
    t.integer  "web_article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_tags", force: :cascade do |t|
    t.string   "label"
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

  create_table "channel_secrets", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "secret_for"
    t.text     "secrets_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_universes", force: :cascade do |t|
    t.text     "universe"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "oauth_token_hashes", force: :cascade do |t|
    t.string   "source"
    t.string   "token"
    t.string   "secret"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_stats", force: :cascade do |t|
    t.text    "stats_hash"
    t.integer "twitter_profile_id"
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

  create_table "tweet_packets", force: :cascade do |t|
    t.text     "tweets_list"
    t.datetime "newest_tweet_at"
    t.datetime "oldest_tweet_at"
    t.integer  "max_id",          limit: 8
    t.integer  "since_id",        limit: 8
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twitter_profiles", force: :cascade do |t|
    t.string   "handle"
    t.string   "location"
    t.string   "bio"
    t.datetime "member_since"
    t.string   "website"
    t.integer  "num_followers"
    t.integer  "num_following"
    t.integer  "num_tweets"
    t.integer  "num_favorites"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "last_tweet"
  end

  create_table "twitter_request_records", force: :cascade do |t|
    t.string   "handle"
    t.integer  "cursor"
    t.string   "request_type"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ran_limit"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "web_articles", force: :cascade do |t|
    t.string   "source"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.string   "original_url"
    t.integer  "tweet_packet_id"
    t.boolean  "fetch_failed"
  end

end
