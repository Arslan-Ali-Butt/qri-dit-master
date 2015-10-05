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

ActiveRecord::Schema.define(version: 20150804151436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_affiliate_chargify_resources", force: true do |t|
    t.string   "base_component_id"
    t.string   "qrids_component_id"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_affiliate_chargify_resources", ["tenant_id"], name: "index_admin_affiliate_chargify_resources_on_tenant_id", using: :btree

  create_table "admin_landlords", force: true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_landlords", ["name"], name: "index_admin_landlords_on_name", unique: true, using: :btree

  create_table "admin_logos", force: true do |t|
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "photo_url"
  end

  create_table "admin_priceplan_addons", force: true do |t|
    t.string   "name"
    t.integer  "starting_number"
    t.integer  "ending_number"
    t.decimal  "unit_price",      precision: 8, scale: 2
    t.integer  "priceplan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "item_name"
  end

  add_index "admin_priceplan_addons", ["priceplan_id"], name: "index_admin_priceplan_addons_on_priceplan_id", using: :btree

  create_table "admin_priceplans", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "qrid_num"
    t.decimal  "price_per_month", precision: 8, scale: 2
    t.decimal  "price_per_year",  precision: 8, scale: 2
    t.integer  "position",                                default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_tenant_notes", force: true do |t|
    t.integer  "tenant_id"
    t.string   "title"
    t.text     "note"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_tenants", force: true do |t|
    t.string   "subdomain"
    t.string   "company_name"
    t.string   "company_website"
    t.string   "name"
    t.string   "phone"
    t.string   "phone_ext"
    t.string   "admin_email"
    t.string   "timezone",                                    default: "Eastern Time (US & Canada)"
    t.string   "host_url"
    t.integer  "priceplan_id"
    t.string   "billing_customer_id"
    t.string   "card_brand"
    t.string   "card_last4",                        limit: 4
    t.string   "billing_recurrence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_notification_time",                default: 7
    t.string   "billing_subscription_id"
    t.boolean  "allow_reporters_to_view_reports",             default: true
    t.boolean  "allow_comment_email_notifications",           default: true
    t.boolean  "metric",                                      default: true
    t.string   "country_code",                                default: "CA"
    t.boolean  "allow_clients_view_comments",                 default: false
    t.boolean  "invite_clients_on_create",                    default: true
    t.integer  "parent_id"
    t.string   "affiliate_status",                            default: "AWAITING_APPROVAL"
    t.boolean  "allow_affiliate_requests",                    default: false
    t.string   "acronym"
    t.string   "stripe_customer_id"
  end

  add_index "admin_tenants", ["subdomain"], name: "index_admin_tenants_on_subdomain", unique: true, using: :btree

  create_table "tenant_addresses", force: true do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "house_number"
    t.string   "street_name"
    t.string   "line_2"
    t.string   "city"
    t.string   "province"
    t.string   "postal_code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_api_tokens", force: true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tenant_api_tokens", ["user_id"], name: "index_tenant_api_tokens_on_user_id", using: :btree

  create_table "tenant_assignment_overrides", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "assignee_id"
    t.integer  "qrid_id"
    t.text     "comment"
    t.string   "status"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "deleted"
    t.boolean  "multiple_instance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "overrided_start_at"
    t.datetime "recurring_until_at"
  end

  add_index "tenant_assignment_overrides", ["assignee_id"], name: "index_tenant_assignment_overrides_on_assignee_id", using: :btree
  add_index "tenant_assignment_overrides", ["assignment_id"], name: "index_tenant_assignment_overrides_on_assignment_id", using: :btree
  add_index "tenant_assignment_overrides", ["qrid_id"], name: "index_tenant_assignment_overrides_on_qrid_id", using: :btree

  create_table "tenant_assignments", force: true do |t|
    t.integer  "assignee_id"
    t.integer  "qrid_id"
    t.text     "comment"
    t.string   "status"
    t.boolean  "permatask"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recurring_until_at"
    t.string   "recurrence"
    t.boolean  "unread"
    t.text     "schedule"
    t.boolean  "confirmed",          default: false
  end

  add_index "tenant_assignments", ["assignee_id"], name: "index_tenant_assignments_on_assignee_id", using: :btree

  create_table "tenant_permatasks", force: true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "task_type"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depth"
    t.boolean  "for_affiliates", default: false
    t.integer  "position"
    t.integer  "children_count"
  end

  add_index "tenant_permatasks", ["parent_id"], name: "index_tenant_permatasks_on_parent_id", using: :btree

  create_table "tenant_permatasks_qrids", id: false, force: true do |t|
    t.integer "qrid_id"
    t.integer "permatask_id"
  end

  add_index "tenant_permatasks_qrids", ["qrid_id"], name: "index_tenant_permatasks_qrids_on_qrid_id", using: :btree

  create_table "tenant_qrid_photos", force: true do |t|
    t.integer  "qrid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "title",              limit: 100
    t.string   "description",        limit: 300
    t.string   "photo_url"
  end

  create_table "tenant_qrids", force: true do |t|
    t.integer  "site_id"
    t.integer  "work_type_id"
    t.string   "name"
    t.decimal  "estimated_duration",              precision: 5, scale: 2
    t.string   "status",                                                  default: "Active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alarm_code"
    t.string   "alarm_safeword"
    t.string   "alarm_company"
    t.string   "key_box_code"
    t.boolean  "delta",                                                   default: true,     null: false
    t.integer  "next_assignment_timestamp"
    t.boolean  "next_assignment_timestamp_stale",                         default: true
    t.integer  "updated_tenant_staff_id"
    t.string   "updated_tenant_staff_type"
    t.integer  "created_tenant_staff_id"
    t.string   "created_tenant_staff_type"
    t.text     "instruction"
  end

  add_index "tenant_qrids", ["delta"], name: "index_tenant_qrids_on_delta", using: :btree

  create_table "tenant_report_notes", force: true do |t|
    t.integer  "report_id"
    t.text     "note"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unread_by_manager", default: true
  end

  create_table "tenant_report_photos", force: true do |t|
    t.integer  "report_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "photo_url"
  end

  create_table "tenant_report_solutions", force: true do |t|
    t.integer  "report_id"
    t.integer  "report_task_id"
    t.text     "description"
    t.boolean  "accepted"
    t.boolean  "declined"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_report_tasks", force: true do |t|
    t.integer  "report_id"
    t.integer  "task_id"
    t.string   "task_type"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_reports", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "qrid_id"
    t.integer  "reporter_id"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "replied_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unread_by_manager"
    t.boolean  "unread_by_client"
    t.boolean  "flagged"
    t.text     "comments"
    t.boolean  "is_permatask_report",                    default: false
    t.integer  "report_unread_notes_count",              default: 0
    t.integer  "logged",                                 default: 0
    t.integer  "latest_unread_client_comment_timestamp", default: 0
    t.datetime "completed_at"
  end

  create_table "tenant_roles", force: true do |t|
    t.string   "name"
    t.integer  "position",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tenant_roles", ["name"], name: "index_tenant_roles_on_name", unique: true, using: :btree

  create_table "tenant_roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "tenant_roles_users", ["role_id"], name: "index_tenant_roles_users_on_role_id", using: :btree
  add_index "tenant_roles_users", ["user_id"], name: "index_tenant_roles_users_on_user_id", using: :btree

  create_table "tenant_sites", force: true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.integer  "zone_id"
    t.string   "alarm_code"
    t.string   "alarm_safeword"
    t.string   "alarm_company"
    t.string   "emergency_number"
    t.decimal  "latitude",                  precision: 10, scale: 7
    t.decimal  "longitude",                 precision: 10, scale: 7
    t.text     "notes"
    t.string   "status",                                             default: "Active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                                              default: true,     null: false
    t.integer  "updated_tenant_staff_id"
    t.string   "updated_tenant_staff_type"
    t.integer  "created_tenant_staff_id"
    t.string   "created_tenant_staff_type"
    t.text     "instruction"
  end

  add_index "tenant_sites", ["delta"], name: "index_tenant_sites_on_delta", using: :btree
  add_index "tenant_sites", ["owner_id"], name: "index_tenant_sites_on_owner_id", using: :btree

  create_table "tenant_staff_work_types_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "work_type_id"
  end

  add_index "tenant_staff_work_types_users", ["user_id"], name: "index_tenant_staff_work_types_users_on_user_id", using: :btree

  create_table "tenant_staff_zones_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "zone_id"
  end

  add_index "tenant_staff_zones_users", ["user_id"], name: "index_tenant_staff_zones_users_on_user_id", using: :btree

  create_table "tenant_tasks", force: true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "task_type"
    t.integer  "work_type_id"
    t.string   "client_type"
    t.boolean  "active"
    t.integer  "qrid_id"
    t.integer  "origin_id"
    t.boolean  "checked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depth"
    t.boolean  "for_affiliates", default: false
    t.integer  "position"
    t.integer  "children_count"
  end

  add_index "tenant_tasks", ["parent_id"], name: "index_tenant_tasks_on_parent_id", using: :btree
  add_index "tenant_tasks", ["qrid_id"], name: "index_tenant_tasks_on_qrid_id", using: :btree

  create_table "tenant_user_imports", force: true do |t|
    t.string   "user_import_file"
    t.integer  "num_users"
    t.integer  "status"
    t.string   "error_messages",   default: [], array: true
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_user_settings", force: true do |t|
    t.integer "user_id"
    t.boolean "getting_started_popup_shown"
    t.boolean "disable_assignment_notifications"
    t.boolean "disable_report_notifications"
    t.boolean "allow_reporting_with_no_assignment", default: false
  end

  add_index "tenant_user_settings", ["user_id"], name: "index_tenant_user_settings_on_user_id", using: :btree

  create_table "tenant_users", force: true do |t|
    t.string   "name"
    t.string   "phone_cell"
    t.string   "phone_landline"
    t.string   "phone_emergency"
    t.string   "phone_emergency_2"
    t.string   "staff_daily_hours"
    t.string   "client_type"
    t.text     "notes"
    t.string   "status",                 default: "Active"
    t.boolean  "super_user",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",       null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,        null: false
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "confirmation_token"
    t.string   "unconfirmed_email"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        default: 0,        null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count"
    t.string   "type"
    t.boolean  "delta",                  default: true,     null: false
    t.datetime "last_report_at"
    t.integer  "time_this_week",         default: 0
    t.integer  "time_this_month",        default: 0
    t.text     "ios_auth_tokens",        default: [],                    array: true
  end

  add_index "tenant_users", ["confirmation_token"], name: "index_tenant_users_on_confirmation_token", unique: true, using: :btree
  add_index "tenant_users", ["delta"], name: "index_tenant_users_on_delta", using: :btree
  add_index "tenant_users", ["email"], name: "index_tenant_users_on_email", unique: true, using: :btree
  add_index "tenant_users", ["invitation_token"], name: "index_tenant_users_on_invitation_token", unique: true, using: :btree
  add_index "tenant_users", ["invited_by_id"], name: "index_tenant_users_on_invited_by_id", using: :btree
  add_index "tenant_users", ["reset_password_token"], name: "index_tenant_users_on_reset_password_token", unique: true, using: :btree
  add_index "tenant_users", ["unlock_token"], name: "index_tenant_users_on_unlock_token", unique: true, using: :btree

  create_table "tenant_work_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fixed",      default: false
  end

  create_table "tenant_zones", force: true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
