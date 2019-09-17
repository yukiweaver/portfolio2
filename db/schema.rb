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

ActiveRecord::Schema.define(version: 2019_09_17_124454) do

  create_table "events", force: :cascade do |t|
    t.integer "room_id"
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.string "event_kbn"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id"], name: "index_events_on_from_user_id"
    t.index ["room_id"], name: "index_events_on_room_id"
    t.index ["to_user_id"], name: "index_events_on_to_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "from_user_status", default: "1"
    t.string "to_user_status", default: "0"
    t.datetime "exit_date", default: "9999-12-31 00:00:00"
    t.datetime "close_date", default: "9999-12-31 00:00:00"
    t.string "from_user_pair_status", default: "0"
    t.string "to_user_pair_status", default: "0"
    t.integer "from_user_id", null: false
    t.integer "to_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id"], name: "index_rooms_on_from_user_id"
    t.index ["to_user_id"], name: "index_rooms_on_to_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "profile"
    t.string "age"
    t.string "income_kbn"
    t.string "business_kbn"
    t.string "area_kbn"
    t.string "free_entry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "sex_kbn"
    t.string "image"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
