# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161106072737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_types", force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badgets", force: :cascade do |t|
    t.integer  "fiscal_year_id",             null: false
    t.integer  "subject_id",                 null: false
    t.integer  "total_badget",   default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "badgets", ["fiscal_year_id", "subject_id"], name: "index_badgets_on_fiscal_year_id_and_subject_id", unique: true, using: :btree
  add_index "badgets", ["fiscal_year_id"], name: "index_badgets_on_fiscal_year_id", using: :btree
  add_index "badgets", ["subject_id"], name: "index_badgets_on_subject_id", using: :btree

  create_table "balances", force: :cascade do |t|
    t.integer  "fiscal_year_id",             null: false
    t.integer  "subject_id",                 null: false
    t.integer  "top_balance",    default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "balances", ["fiscal_year_id", "subject_id"], name: "index_balances_on_fiscal_year_id_and_subject_id", unique: true, using: :btree
  add_index "balances", ["fiscal_year_id"], name: "index_balances_on_fiscal_year_id", using: :btree
  add_index "balances", ["subject_id"], name: "index_balances_on_subject_id", using: :btree

  create_table "fiscal_years", force: :cascade do |t|
    t.integer  "user_id",                                  null: false
    t.integer  "account_type_id",                          null: false
    t.integer  "subject_template_type_id",                 null: false
    t.string   "organization_name",                        null: false
    t.string   "title",                                    null: false
    t.date     "date_from",                                null: false
    t.date     "date_to",                                  null: false
    t.boolean  "locked",                   default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "tab_type"
    t.boolean  "list_desc"
  end

  add_index "fiscal_years", ["account_type_id"], name: "index_fiscal_years_on_account_type_id", using: :btree
  add_index "fiscal_years", ["subject_template_type_id"], name: "index_fiscal_years_on_subject_template_type_id", using: :btree
  add_index "fiscal_years", ["user_id"], name: "index_fiscal_years_on_user_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.integer  "fiscal_year_id",                    null: false
    t.date     "journal_date",                      null: false
    t.integer  "subject_debit_id",                  null: false
    t.integer  "subject_credit_id",                 null: false
    t.integer  "price",             default: 0,     null: false
    t.string   "comment"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "mark",              default: false, null: false
  end

  add_index "journals", ["fiscal_year_id"], name: "index_journals_on_fiscal_year_id", using: :btree
  add_index "journals", ["subject_credit_id"], name: "index_journals_on_subject_credit_id", using: :btree
  add_index "journals", ["subject_debit_id"], name: "index_journals_on_subject_debit_id", using: :btree

  create_table "subject_template_types", force: :cascade do |t|
    t.integer  "account_type_id", null: false
    t.string   "name",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "subject_templates", force: :cascade do |t|
    t.integer  "subject_template_type_id", null: false
    t.integer  "subject_type_id",          null: false
    t.string   "code",                     null: false
    t.string   "name",                     null: false
    t.integer  "report1_location"
    t.integer  "report2_location"
    t.integer  "report3_location"
    t.integer  "report4_location"
    t.integer  "report5_location"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "subject_templates", ["subject_template_type_id"], name: "index_subject_templates_on_subject_template_type_id", using: :btree

  create_table "subject_types", force: :cascade do |t|
    t.integer  "account_type_id",       null: false
    t.string   "name",                  null: false
    t.string   "short_name",            null: false
    t.string   "debit_and_credit_name", null: false
    t.string   "profit_and_loss_name",  null: false
    t.boolean  "debit",                 null: false
    t.boolean  "credit",                null: false
    t.boolean  "debit_and_credit",      null: false
    t.boolean  "profit_and_loss",       null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "subject_types", ["account_type_id"], name: "index_subject_types_on_account_type_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.integer  "fiscal_year_id",                             null: false
    t.integer  "subject_type_id",                            null: false
    t.string   "code",             limit: 4,                 null: false
    t.string   "name",                                       null: false
    t.integer  "report1_location"
    t.integer  "report2_location"
    t.integer  "report3_location"
    t.integer  "report4_location"
    t.integer  "report5_location"
    t.boolean  "from_template",              default: false, null: false
    t.boolean  "disabled",                   default: false, null: false
    t.boolean  "dash_board",                 default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "subjects", ["fiscal_year_id", "code"], name: "index_subjects_on_fiscal_year_id_and_code", unique: true, using: :btree
  add_index "subjects", ["fiscal_year_id"], name: "index_subjects_on_fiscal_year_id", using: :btree
  add_index "subjects", ["subject_type_id"], name: "index_subjects_on_subject_type_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                           null: false
    t.string   "email_for_index",                 null: false
    t.string   "name",                            null: false
    t.string   "hashed_password"
    t.boolean  "suspended",       default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin_user"
  end

  add_index "users", ["email_for_index"], name: "index_users_on_email_for_index", unique: true, using: :btree

  create_table "watch_users", force: :cascade do |t|
    t.integer  "fiscal_year_id",                 null: false
    t.integer  "user_id",                        null: false
    t.boolean  "can_modify",     default: false, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "watch_users", ["fiscal_year_id", "user_id"], name: "index_watch_users_on_fiscal_year_id_and_user_id", unique: true, using: :btree
  add_index "watch_users", ["fiscal_year_id"], name: "index_watch_users_on_fiscal_year_id", using: :btree
  add_index "watch_users", ["user_id"], name: "index_watch_users_on_user_id", using: :btree

  add_foreign_key "badgets", "fiscal_years"
  add_foreign_key "badgets", "subjects"
  add_foreign_key "balances", "fiscal_years"
  add_foreign_key "balances", "subjects"
  add_foreign_key "fiscal_years", "subject_template_types"
  add_foreign_key "fiscal_years", "users"
  add_foreign_key "journals", "fiscal_years"
  add_foreign_key "journals", "subjects", column: "subject_credit_id"
  add_foreign_key "journals", "subjects", column: "subject_debit_id"
  add_foreign_key "subject_template_types", "account_types"
  add_foreign_key "subject_templates", "subject_template_types"
  add_foreign_key "subject_templates", "subject_types"
  add_foreign_key "subject_types", "account_types"
  add_foreign_key "subjects", "fiscal_years"
  add_foreign_key "subjects", "subject_types"
  add_foreign_key "watch_users", "fiscal_years"
  add_foreign_key "watch_users", "users"
end
