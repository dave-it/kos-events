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

ActiveRecord::Schema[8.1].define(version: 2026_11_07_210000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "invitations", force: :cascade do |t|
    t.bigint "rider_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.bigint "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["rider_id"], name: "index_invitations_on_rider_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "riders", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "nickname"
    t.boolean "female", default: false, null: false
    t.string "nation"
    t.date "birthday"
    t.string "email", null: false
    t.string "organization"
    t.text "info"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public_profile", default: false, null: false
    t.datetime "public_profile_consented_at"
    t.index ["email"], name: "index_riders_on_email", unique: true
    t.index ["public_profile"], name: "index_riders_on_public_profile"
    t.index ["user_id"], name: "index_riders_on_user_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "rider", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "invitations", "riders"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "riders", "users"
  add_foreign_key "sessions", "users"
end
