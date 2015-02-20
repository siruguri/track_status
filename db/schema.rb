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

ActiveRecord::Schema.define(version: 20150220045315) do

  create_table "bin_records", force: :cascade do |t|
    t.string "number"
    t.string "brand"
    t.string "sub_brand"
    t.string "country_code"
    t.string "country_name"
    t.string "bank"
    t.string "card_type"
    t.string "card_category"
    t.float  "lat"
    t.float  "long"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "source"
    t.string "description"
    t.text   "message"
  end

end
