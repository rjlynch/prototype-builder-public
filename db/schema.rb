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

ActiveRecord::Schema[8.1].define(version: 2026_06_11_144024) do
  create_table "components", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hint"
    t.string "kind", null: false
    t.string "label"
    t.string "name"
    t.integer "page_id", null: false
    t.integer "position", null: false
    t.text "text"
    t.datetime "updated_at", null: false
    t.index ["page_id", "position"], name: "index_components_on_page_id_and_position", unique: true
    t.index ["page_id"], name: "index_components_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "wizard_id", null: false
    t.index ["wizard_id", "position"], name: "index_pages_on_wizard_id_and_position", unique: true
    t.index ["wizard_id"], name: "index_pages_on_wizard_id"
  end

  create_table "wizards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "components", "pages"
  add_foreign_key "pages", "wizards"
end
