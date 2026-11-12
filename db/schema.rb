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

ActiveRecord::Schema[8.1].define(version: 2026_11_12_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "female", default: false, null: false
    t.boolean "juniors", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.index ["event_id", "name"], name: "index_categories_on_event_id_and_name", unique: true
    t.index ["event_id"], name: "index_categories_on_event_id"
    t.index ["legacy_id"], name: "index_categories_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.text "description"
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.text "info_de"
    t.text "info_en"
    t.string "registration_url"
    t.datetime "registration_deadline"
    t.index ["legacy_id"], name: "index_events_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
    t.index ["published"], name: "index_events_on_published"
    t.index ["starts_at"], name: "index_events_on_starts_at"
  end

  create_table "heat_entries", force: :cascade do |t|
    t.bigint "heat_id", null: false
    t.bigint "registration_id", null: false
    t.integer "place"
    t.integer "gate_pick"
    t.string "gate_color"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["heat_id", "registration_id"], name: "index_heat_entries_on_heat_id_and_registration_id", unique: true
    t.index ["heat_id"], name: "index_heat_entries_on_heat_id"
    t.index ["legacy_id"], name: "index_heat_entries_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
    t.index ["registration_id"], name: "index_heat_entries_on_registration_id"
  end

  create_table "heats", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.integer "round", default: 0, null: false
    t.integer "number", default: 1, null: false
    t.boolean "lcq", default: false, null: false
    t.boolean "finished", default: false, null: false
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "round", "number", "lcq"], name: "index_heats_on_category_id_and_round_and_number_and_lcq"
    t.index ["category_id"], name: "index_heats_on_category_id"
    t.index ["legacy_id"], name: "index_heats_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "rider_id"
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.bigint "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "rider", null: false
    t.string "locale", default: "de", null: false
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["rider_id"], name: "index_invitations_on_rider_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title_de", null: false
    t.string "title_en", null: false
    t.text "body_de", default: "", null: false
    t.text "body_en", default: "", null: false
    t.string "nav", default: "none", null: false
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "category_id", null: false
    t.bigint "rider_id", null: false
    t.integer "start_number"
    t.datetime "waiver_signed_at"
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.integer "trial_number"
    t.json "qualification_times", default: [], null: false
    t.float "points"
    t.index ["category_id", "rider_id"], name: "index_registrations_on_category_id_and_rider_id", unique: true
    t.index ["category_id", "start_number"], name: "index_registrations_on_category_id_and_start_number", unique: true, where: "(start_number IS NOT NULL)"
    t.index ["category_id"], name: "index_registrations_on_category_id"
    t.index ["event_id"], name: "index_registrations_on_event_id"
    t.index ["legacy_id"], name: "index_registrations_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
    t.index ["rider_id"], name: "index_registrations_on_rider_id"
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
    t.string "locale", default: "de", null: false
    t.integer "legacy_id"
    t.index ["email"], name: "index_riders_on_email", unique: true
    t.index ["legacy_id"], name: "index_riders_on_legacy_id", unique: true, where: "(legacy_id IS NOT NULL)"
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

  add_foreign_key "categories", "events"
  add_foreign_key "heat_entries", "heats"
  add_foreign_key "heat_entries", "registrations"
  add_foreign_key "heats", "categories"
  add_foreign_key "invitations", "riders"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "registrations", "categories"
  add_foreign_key "registrations", "events"
  add_foreign_key "registrations", "riders"
  add_foreign_key "riders", "users"
  add_foreign_key "sessions", "users"
end
