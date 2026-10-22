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

ActiveRecord::Schema[8.1].define(version: 2026_10_22_000000) do
  create_table "campaign_memberships", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "profile_id", null: false
    t.boolean "is_dm", default: false, null: false
    t.string "campaign_name_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "profile_id"], name: "index_campaign_memberships_on_campaign_id_and_profile_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_memberships_on_campaign_id"
    t.index ["profile_id", "campaign_name_key"], name: "index_campaign_memberships_on_dm_profile_and_name_key", unique: true, where: "is_dm = TRUE"
    t.index ["profile_id"], name: "index_campaign_memberships_on_profile_id"
    t.check_constraint "(is_dm = TRUE AND campaign_name_key IS NOT NULL) OR (is_dm = FALSE AND campaign_name_key IS NULL)", name: "campaign_memberships_dm_name_key_presence"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remember_created_at"
    t.index "LOWER(email)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "campaign_memberships", "campaigns"
  add_foreign_key "campaign_memberships", "profiles"
  add_foreign_key "profiles", "users"
end
