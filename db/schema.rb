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

ActiveRecord::Schema.define(version: 20151003035350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_types", force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  add_foreign_key "subject_templates", "subject_template_types"
  add_foreign_key "subject_templates", "subject_types"
  add_foreign_key "subject_types", "account_types"
end
