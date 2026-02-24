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

ActiveRecord::Schema[7.2].define(version: 2026_02_14_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "training_module", null: false
    t.float "score"
    t.boolean "passed"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["score", "passed"], name: "index_assessments_on_score_and_passed"
    t.index ["user_id"], name: "index_assessments_on_user_id"
  end

  create_table "confidence_check_progress", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "module_name", null: false
    t.string "check_type", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "skipped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "module_name", "check_type"], name: "index_confidence_check_on_user_module_type", unique: true
    t.index ["user_id"], name: "index_confidence_check_progress_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_events_on_name_and_time"
    t.index ["properties"], name: "index_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_events_on_user_id"
    t.index ["visit_id"], name: "index_events_on_visit_id"
  end

  create_table "mail_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "template"
    t.jsonb "personalisation"
    t.jsonb "callback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_mail_events_on_user_id"
  end

  create_table "module_releases", force: :cascade do |t|
    t.bigint "release_id", null: false
    t.integer "module_position", null: false
    t.string "name", null: false
    t.datetime "first_published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["module_position"], name: "index_module_releases_on_module_position", unique: true
    t.index ["name"], name: "index_module_releases_on_name", unique: true
    t.index ["release_id"], name: "index_module_releases_on_release_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "body"
    t.string "training_module"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "que_jobs", comment: "7", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.timestamptz "run_at", default: -> { "now()" }, null: false
    t.text "job_class", null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error_message"
    t.text "queue", default: "default", null: false
    t.text "last_error_backtrace"
    t.timestamptz "finished_at"
    t.timestamptz "expired_at"
    t.jsonb "args", default: [], null: false
    t.jsonb "data", default: {}, null: false
    t.integer "job_schema_version", null: false
    t.jsonb "kwargs", default: {}, null: false
    t.index ["args"], name: "que_jobs_args_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["data"], name: "que_jobs_data_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["job_class"], name: "que_scheduler_job_in_que_jobs_unique_index", unique: true, where: "(job_class = 'Que::Scheduler::SchedulerJob'::text)"
    t.index ["job_schema_version", "queue", "priority", "run_at", "id"], name: "que_poll_idx", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.index ["kwargs"], name: "que_jobs_kwargs_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.check_constraint "char_length(\nCASE job_class\n    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN (args -> 0) ->> 'job_class'::text\n    ELSE job_class\nEND) <= 200", name: "job_class_length"
    t.check_constraint "char_length(last_error_message) <= 500 AND char_length(last_error_backtrace) <= 10000", name: "error_length"
    t.check_constraint "char_length(queue) <= 100", name: "queue_length"
    t.check_constraint "jsonb_typeof(args) = 'array'::text", name: "valid_args"
    t.check_constraint "jsonb_typeof(data) = 'object'::text AND (NOT data ? 'tags'::text OR jsonb_typeof(data -> 'tags'::text) = 'array'::text AND jsonb_array_length(data -> 'tags'::text) <= 5 AND que_validate_tags(data -> 'tags'::text))", name: "valid_data"
  end

  create_table "que_lockers", primary_key: "pid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "worker_count", null: false
    t.integer "worker_priorities", null: false, array: true
    t.integer "ruby_pid", null: false
    t.text "ruby_hostname", null: false
    t.text "queues", null: false, array: true
    t.boolean "listening", null: false
    t.integer "job_schema_version", default: 1
    t.check_constraint "array_ndims(queues) = 1 AND array_length(queues, 1) IS NOT NULL", name: "valid_queues"
    t.check_constraint "array_ndims(worker_priorities) = 1 AND array_length(worker_priorities, 1) IS NOT NULL", name: "valid_worker_priorities"
  end

  create_table "que_scheduler_audit", primary_key: "scheduler_job_id", id: :bigint, default: nil, comment: "8", force: :cascade do |t|
    t.timestamptz "executed_at", null: false
  end

  create_table "que_scheduler_audit_enqueued", force: :cascade do |t|
    t.bigint "scheduler_job_id", null: false
    t.string "job_class", limit: 255, null: false
    t.string "queue", limit: 255
    t.integer "priority"
    t.jsonb "args", null: false
    t.bigint "job_id"
    t.timestamptz "run_at"
    t.index ["args"], name: "que_scheduler_audit_enqueued_args"
    t.index ["job_class"], name: "que_scheduler_audit_enqueued_job_class"
    t.index ["job_id"], name: "que_scheduler_audit_enqueued_job_id"
  end

  create_table "que_values", primary_key: "key", id: :text, force: :cascade do |t|
    t.jsonb "value", default: {}, null: false
    t.check_constraint "jsonb_typeof(value) = 'object'::text", name: "valid_value"
  end

  create_table "releases", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "properties", default: {}, null: false
    t.datetime "time", null: false
    t.index ["name", "time"], name: "index_releases_on_name_and_time"
    t.index ["properties"], name: "index_releases_on_properties", opclass: :jsonb_path_ops, using: :gin
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "user_id"
    t.string "training_module", null: false
    t.string "question_name", null: false
    t.jsonb "answers", default: []
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "question_type"
    t.bigint "assessment_id"
    t.text "text_input"
    t.bigint "visit_id"
    t.index ["assessment_id"], name: "index_responses_on_assessment_id"
    t.index ["user_id", "training_module", "question_name"], name: "user_question"
    t.index ["user_id"], name: "index_responses_on_user_id"
    t.index ["visit_id"], name: "index_responses_on_visit_id"
  end

  create_table "user_module_progress", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "module_name", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.jsonb "visited_pages", default: {}
    t.string "last_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "module_name"], name: "index_user_module_progress_on_user_id_and_module_name", unique: true
    t.index ["user_id"], name: "index_user_module_progress_on_user_id"
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
    t.boolean "private_beta_registration_complete", default: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "unlock_token"
    t.string "setting_type"
    t.string "setting_type_other"
    t.jsonb "module_time_to_completion", default: {}, null: false
    t.datetime "terms_and_conditions_agreed_at"
    t.boolean "display_whats_new", default: false
    t.string "local_authority"
    t.string "role_type"
    t.string "role_type_other"
    t.string "setting_type_id"
    t.boolean "registration_complete", default: false
    t.datetime "closed_at"
    t.string "closed_reason"
    t.string "closed_reason_custom"
    t.boolean "training_emails"
    t.string "gov_one_id"
    t.string "early_years_experience"
    t.boolean "research_participant"
    t.jsonb "notify_callback"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gov_one_id"], name: "index_users_on_gov_one_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  create_table "visits", force: :cascade do |t|
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
    t.index ["user_id"], name: "index_visits_on_user_id"
    t.index ["visit_token"], name: "index_visits_on_visit_token", unique: true
  end

  add_foreign_key "assessments", "users"
  add_foreign_key "confidence_check_progress", "users"
  add_foreign_key "mail_events", "users"
  add_foreign_key "module_releases", "releases"
  add_foreign_key "notes", "users"
  add_foreign_key "que_scheduler_audit_enqueued", "que_scheduler_audit", column: "scheduler_job_id", primary_key: "scheduler_job_id", name: "que_scheduler_audit_enqueued_scheduler_job_id_fkey"
  add_foreign_key "responses", "assessments"
  add_foreign_key "responses", "users"
  add_foreign_key "responses", "visits"
  add_foreign_key "user_module_progress", "users"
end
