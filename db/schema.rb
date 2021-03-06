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

ActiveRecord::Schema.define(version: 2019_05_16_122259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "menu_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "restaurant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "pos_id"
    t.uuid "foodapp_id"
  end

  create_table "menu_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.uuid "pos_menu_category_id"
    t.integer "price"
    t.integer "cooking_time"
    t.integer "kcal"
    t.uuid "restaurant_id"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "pos_id"
    t.uuid "foodapp_id"
    t.uuid "foodapp_menu_category_id"
    t.string "code"
  end

  create_table "orders", force: :cascade do |t|
    t.uuid "restaurant_id"
    t.uuid "pos_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pos_order_number"
    t.uuid "foodapp_order_id"
    t.integer "status", default: 0
  end

  create_table "restaurants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.string "pos_url"
    t.string "pos_login"
    t.string "pos_password"
    t.integer "pos_name"
    t.uuid "pos_id"
    t.uuid "foodapp_id"
    t.string "currency"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
