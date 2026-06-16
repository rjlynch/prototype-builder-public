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

ActiveRecord::Schema[8.1].define(version: 2026_06_16_100005) do
  create_table "branch_rules", force: :cascade do |t|
    t.integer "component_id", null: false
    t.datetime "created_at", null: false
    t.string "input_name", default: "", null: false
    t.integer "position", null: false
    t.string "target_slug", default: "", null: false
    t.datetime "updated_at", null: false
    t.string "value", default: "", null: false
    t.index ["component_id", "position"], name: "index_branch_rules_on_component_id_and_position", unique: true
    t.index ["component_id"], name: "index_branch_rules_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hint"
    t.string "kind", null: false
    t.string "label"
    t.boolean "list_spaced", default: false, null: false
    t.string "list_style", default: "none", null: false
    t.string "name"
    t.text "options"
    t.integer "page_id", null: false
    t.integer "position", null: false
    t.text "text"
    t.boolean "title_as_label", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "position"], name: "index_components_on_page_id_and_position", unique: true
    t.index ["page_id"], name: "index_components_on_page_id"
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
    t.integer "position", null: false
    t.string "slug", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "wizard_id", null: false
    t.index ["wizard_id", "position"], name: "index_pages_on_wizard_id_and_position", unique: true
    t.index ["wizard_id", "slug"], name: "index_pages_on_wizard_id_and_slug", unique: true
    t.index ["wizard_id"], name: "index_pages_on_wizard_id"
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

  add_foreign_key "branch_rules", "components"
  add_foreign_key "components", "pages"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "pages", "wizards"
  add_foreign_key "users", "teams", column: "default_team_id"
  add_foreign_key "wizards", "teams"
end
