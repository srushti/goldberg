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

ActiveRecord::Schema.define(:version => 20111125054924) do

  create_table "builds", :force => true do |t|
    t.integer  "project_id"
    t.integer  "number"
    t.string   "revision"
    t.string   "change_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "ruby"
    t.string   "environment_string"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "build_requested", :default => false
    t.string   "branch"
    t.datetime "next_build_at"
    t.string   "scm"
  end

  create_table "role_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "role_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
