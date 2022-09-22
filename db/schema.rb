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

ActiveRecord::Schema[7.0].define(version: 2022_09_21_145201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "user_answers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "questionnaire_id", null: false
    t.string "question"
    t.string "answer"
    t.boolean "correct"
    t.boolean "archived"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "module"
    t.string "name"
    t.string "assessments_type"
    t.bigint "user_assessment_id"
    t.index ["questionnaire_id", "user_id"], name: "index_user_answers_on_questionnaire_id_and_user_id"
    t.index ["questionnaire_id"], name: "index_user_answers_on_questionnaire_id"
    t.index ["user_assessment_id"], name: "index_user_answers_on_user_assessment_id"
    t.index ["user_id"], name: "index_user_answers_on_user_id"
  end

  create_table "user_assessments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "score"
    t.string "status"
    t.string "module"
    t.string "assessments_type"
    t.boolean "archived"
    t.datetime "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["score", "status"], name: "index_user_assessments_on_score_and_status"
    t.index ["user_id"], name: "index_user_assessments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "registration_complete"
    t.string "postcode"
    t.string "ofsted_number"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.string "unlock_token"
    t.string "setting_type"
    t.string "setting_type_other"
    t.datetime "terms_and_conditions_agreed_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  add_foreign_key "user_answers", "user_assessments"
  add_foreign_key "user_answers", "users"
  add_foreign_key "user_assessments", "users"
end
