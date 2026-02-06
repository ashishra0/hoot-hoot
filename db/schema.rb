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

ActiveRecord::Schema[8.1].define(version: 2026_02_06_104134) do
  create_table "friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_streak", default: 0, null: false
    t.boolean "friend_hooted_today", default: false, null: false
    t.integer "friend_id", null: false
    t.integer "longest_streak", default: 0, null: false
    t.date "streak_date"
    t.datetime "updated_at", null: false
    t.boolean "user_hooted_today", default: false, null: false
    t.integer "user_id", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "hoots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "friendship_id", null: false
    t.integer "receiver_id", null: false
    t.integer "sender_id", null: false
    t.index ["friendship_id"], name: "index_hoots_on_friendship_id"
    t.index ["receiver_id"], name: "index_hoots_on_receiver_id"
    t.index ["sender_id", "receiver_id", "created_at"], name: "index_hoots_on_sender_id_and_receiver_id_and_created_at"
    t.index ["sender_id"], name: "index_hoots_on_sender_id"
  end

  create_table "invites", force: :cascade do |t|
    t.datetime "claimed_at"
    t.integer "claimed_by_id"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["claimed_by_id"], name: "index_invites_on_claimed_by_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
    t.index ["user_id"], name: "index_invites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "hoots", "friendships"
  add_foreign_key "hoots", "users", column: "receiver_id"
  add_foreign_key "hoots", "users", column: "sender_id"
  add_foreign_key "invites", "users"
  add_foreign_key "invites", "users", column: "claimed_by_id"
end
