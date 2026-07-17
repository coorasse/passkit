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

ActiveRecord::Schema[7.1].define(version: 2024_04_11_013721) do
  create_table "passkit_devices", force: :cascade do |t|
    t.string "identifier"
    t.string "push_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "passkit_logs", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "passkit_passes", force: :cascade do |t|
    t.string "generator_type"
    t.string "klass"
    t.bigint "generator_id"
    t.string "serial_number"
    t.string "authentication_token"
    t.json "data"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["generator_type", "generator_id"], name: "index_passkit_passes_on_generator"
  end

  create_table "passkit_registrations", force: :cascade do |t|
    t.integer "passkit_pass_id"
    t.integer "passkit_device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passkit_device_id"], name: "index_passkit_registrations_on_passkit_device_id"
    t.index ["passkit_pass_id"], name: "index_passkit_registrations_on_passkit_pass_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "tickets", "users"
end
