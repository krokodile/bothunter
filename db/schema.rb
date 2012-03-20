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

ActiveRecord::Schema.define(:version => 20120319074751) do

  create_table "groups", :force => true do |t|
    t.string   "domain"
    t.string   "title"
    t.string   "gid",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "groups", ["gid"], :name => "index_groups_on_gid"

  create_table "groups_people", :force => true do |t|
    t.integer "group_id"
    t.integer "person_id"
  end

  create_table "groups_users", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "provider"
    t.string   "domain"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "people", :force => true do |t|
    t.datetime "bdate"
    t.string   "uid"
    t.string   "domain"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "state"
    t.string   "photo"
    t.integer  "friends_count"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "people", ["uid"], :name => "index_people_on_uid"

  create_table "promocodes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "groups_limit"
    t.integer  "people_limit"
    t.string   "code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "promocodes", ["code"], :name => "index_promocodes_on_code"

  create_table "users", :force => true do |t|
    t.boolean  "approved"
    t.string   "full_name"
    t.string   "phone_number"
    t.string   "company"
    t.string   "message"
    t.string   "rights"
    t.integer  "groups_limit",           :default => 0
    t.integer  "people_limit",           :default => 100
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "email",                  :default => "",  :null => false
    t.string   "encrypted_password",     :default => "",  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wall_posts", :force => true do |t|
    t.integer  "person_id"
    t.boolean  "own_post",       :default => false
    t.string   "post_id",                           :null => false
    t.string   "src"
    t.string   "copy_post_id"
    t.integer  "comments_count"
    t.integer  "likes_count"
    t.datetime "pub_date"
    t.text     "text"
  end

end
