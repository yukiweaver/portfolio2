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

ActiveRecord::Schema.define(version: 2019_09_09_124338) do

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "profile"
    t.integer "age"
    t.string "income_kbn"
    t.string "business_kbn"
    t.string "area_kbn"
    t.string "free_entry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "sex_kbn"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
