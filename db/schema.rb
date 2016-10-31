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

ActiveRecord::Schema.define(version: 20161031155919) do

  create_table "article_categories", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_states", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: :cascade do |t|
    t.string   "title"
    t.string   "abstract"
    t.string   "image"
    t.string   "body"
    t.datetime "date"
    t.string   "web_url"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_views"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "keywords"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "article_logo"
    t.string   "sidebar_logo"
  end

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sources", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_states", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
