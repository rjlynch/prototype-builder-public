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

ActiveRecord::Schema[8.1].define(version: 2026_06_22_130000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "branch_rules", force: :cascade do |t|
    t.integer "component_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.string "target_slug", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id", "position"], name: "index_branch_rules_on_component_id_and_position", unique: true
    t.index ["component_id"], name: "index_branch_rules_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "button_style", default: "continue", null: false
    t.datetime "created_at", null: false
    t.boolean "display_as_link", default: false, null: false
    t.string "hint"
    t.boolean "in_panel", default: false, null: false
    t.boolean "inline", default: false, null: false
    t.string "kind", null: false
    t.string "label"
    t.boolean "list_spaced", default: false, null: false
    t.string "list_style", default: "none", null: false
    t.string "name"
    t.text "options"
    t.integer "page_id", null: false
    t.integer "position", null: false
    t.string "source_key", default: "", null: false
    t.text "summary_keys", default: "", null: false
    t.string "target_slug", default: "", null: false
    t.text "text"
    t.boolean "title_as_label", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "position"], name: "index_components_on_page_id_and_position", unique: true
    t.index ["page_id"], name: "index_components_on_page_id"
  end

  create_table "conditions", force: :cascade do |t|
    t.integer "branch_rule_id", null: false
    t.datetime "created_at", null: false
    t.string "input_name", default: "", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.string "value", default: "", null: false
    t.index ["branch_rule_id", "position"], name: "index_conditions_on_branch_rule_id_and_position", unique: true
    t.index ["branch_rule_id"], name: "index_conditions_on_branch_rule_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id", "team_id"], name: "index_memberships_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.boolean "back_link", default: true, null: false
    t.string "caption", default: "", null: false
    t.datetime "created_at", null: false
    t.string "heading_size", default: "l", null: false
    t.string "panel_style", default: "none", null: false
    t.integer "position", null: false
    t.string "slug", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "wizard_id", null: false
    t.index ["wizard_id", "position"], name: "index_pages_on_wizard_id_and_position", unique: true
    t.index ["wizard_id", "slug"], name: "index_pages_on_wizard_id_and_slug", unique: true
    t.index ["wizard_id"], name: "index_pages_on_wizard_id"
  end

  create_table "signups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "default_team_id", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.datetime "last_signed_in_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["default_team_id"], name: "index_users_on_default_team_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "wizards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_wizards_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "branch_rules", "components"
  add_foreign_key "components", "pages"
  add_foreign_key "conditions", "branch_rules"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "pages", "wizards"
  add_foreign_key "users", "teams", column: "default_team_id"
  add_foreign_key "wizards", "teams"
end
