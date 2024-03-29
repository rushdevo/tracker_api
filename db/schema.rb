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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121011185254) do

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "invitation_id"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["invitation_id"], :name => "index_friendships_on_invitation_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "games", :force => true do |t|
    t.integer  "owner_id"
    t.datetime "start_time"
    t.string   "state"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "games", ["owner_id"], :name => "index_games_on_owner_id"

  create_table "invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "invitee_id"
    t.string   "email"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "token",      :limit => 20
    t.boolean  "accepted"
  end

  add_index "invitations", ["invitee_id"], :name => "index_invitations_on_invitee_id"
  add_index "invitations", ["token"], :name => "index_invitations_on_token"
  add_index "invitations", ["user_id"], :name => "index_invitations_on_user_id"

  create_table "user_games", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_games", ["game_id"], :name => "index_user_games_on_game_id"
  add_index "user_games", ["user_id"], :name => "index_user_games_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                                  :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
