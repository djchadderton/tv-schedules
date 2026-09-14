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

ActiveRecord::Schema[8.1].define(version: 2026_09_12_111628) do
  create_table "channels", force: :cascade do |t|
    t.string "channel_id"
    t.string "icon"
    t.string "name"
  end

  create_table "programmes", force: :cascade do |t|
    t.string "channel_id", null: false
    t.text "description"
    t.datetime "ends_at"
    t.integer "episode"
    t.string "icon"
    t.boolean "premiere", default: false
    t.integer "series"
    t.datetime "starts_at"
    t.string "title"
  end
end
