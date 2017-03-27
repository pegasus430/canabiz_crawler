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

ActiveRecord::Schema.define(version: 20170326035356) do

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
    t.integer  "num_views",         default: 0
    t.boolean  "include_in_digest"
    t.string   "remote_image_url"
    t.integer  "external_visits",   default: 0
    t.string   "slug"
  end

  add_index "articles", ["slug"], name: "index_articles_on_slug", unique: true

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "keywords"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true

  create_table "digest_emails", force: :cascade do |t|
    t.string  "email"
    t.boolean "active"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "name"
  end

  create_table "sort_options", force: :cascade do |t|
    t.string  "name"
    t.string  "query"
    t.string  "direction"
    t.integer "num_clicks"
  end

  create_table "source_hashtags", force: :cascade do |t|
    t.integer "source_id"
    t.integer "hashtag_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "article_logo"
    t.string   "sidebar_logo"
    t.integer  "external_article_visits", default: 0
    t.string   "slug"
    t.datetime "last_run"
  end

  add_index "sources", ["slug"], name: "index_sources_on_slug", unique: true

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "slug"
  end

  add_index "states", ["slug"], name: "index_states_on_slug", unique: true

  create_table "user_articles", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "user_id"
    t.boolean  "saved"
    t.boolean  "viewed_internally"
    t.boolean  "viewed_externally"
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
    t.string   "slug"
    t.string   "password_reset_token"
  end

  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token"
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true

end
