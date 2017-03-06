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

ActiveRecord::Schema.define(version: 20170223064658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beds", force: :cascade do |t|
    t.integer  "yard_id"
    t.string   "name"
    t.boolean  "attached_to_house",      default: false
    t.string   "orientation"
    t.float    "width"
    t.float    "depth"
    t.string   "sunlight_morning"
    t.string   "sunlight_afternoon"
    t.boolean  "watered",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "template_id"
    t.jsonb    "template_placements",    default: {}
    t.jsonb    "template_plant_mapping", default: {}
    t.index ["yard_id"], name: "index_beds_on_yard_id", using: :btree
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
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "yards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "zipcode"
    t.string   "zone"
    t.string   "soil"
    t.jsonb    "preferred_plant_types"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["user_id"], name: "index_yards_on_user_id", using: :btree
    t.index ["zipcode"], name: "index_yards_on_zipcode", using: :btree
    t.index ["zone"], name: "index_yards_on_zone", using: :btree
  end

end
