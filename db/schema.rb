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

ActiveRecord::Schema.define(version: 20180222183100) do

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

  create_table "average_prices", force: :cascade do |t|
    t.integer  "product_id"
    t.decimal  "average_price"
    t.string   "average_price_unit"
    t.decimal  "units_sold"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "display_order"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "keywords"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "category_type"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true

  create_table "digest_emails", force: :cascade do |t|
    t.string  "email"
    t.boolean "active"
  end

  create_table "dispensaries", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.string   "location"
    t.string   "city"
    t.string   "about"
    t.string   "slug"
    t.integer  "state_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dispensaries", ["slug"], name: "index_dispensaries_on_slug", unique: true

  create_table "dispensary_source_products", force: :cascade do |t|
    t.integer  "dispensary_source_id"
    t.integer  "product_id"
    t.string   "image"
    t.decimal  "price"
    t.decimal  "price_gram"
    t.decimal  "price_eighth"
    t.decimal  "price_quarter"
    t.decimal  "price_half_gram"
    t.decimal  "price_two_grams"
    t.decimal  "price_half_ounce"
    t.decimal  "price_ounce"
    t.decimal  "price_80mg"
    t.decimal  "price_160mg"
    t.decimal  "price_180mg"
    t.decimal  "price_100mg"
    t.decimal  "price_40mg"
    t.decimal  "price_25mg"
    t.decimal  "price_150mg"
    t.decimal  "price_10mg"
    t.decimal  "price_50mg"
    t.decimal  "price_240mg"
    t.decimal  "price_1mg"
    t.decimal  "price_2_5mg"
    t.decimal  "one"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dispensary_sources", force: :cascade do |t|
    t.integer  "dispensary_id"
    t.integer  "source_id"
    t.integer  "state_id"
    t.string   "name"
    t.string   "slug"
    t.string   "image"
    t.string   "location"
    t.string   "city"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "source_rating"
    t.string   "source_url"
    t.time     "monday_open_time"
    t.time     "tuesday_open_time"
    t.time     "wednesday_open_time"
    t.time     "thursday_open_time"
    t.time     "friday_open_time"
    t.time     "saturday_open_time"
    t.time     "sunday_open_time"
    t.time     "monday_close_time"
    t.time     "tuesday_close_time"
    t.time     "wednesday_close_time"
    t.time     "thursday_close_time"
    t.time     "friday_close_time"
    t.time     "saturday_close_time"
    t.time     "sunday_close_time"
    t.string   "facebook"
    t.string   "instagram"
    t.string   "twitter"
    t.string   "website"
    t.string   "email"
    t.string   "phone"
    t.integer  "min_age"
    t.datetime "last_menu_update"
    t.string   "street"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dispensary_sources", ["slug"], name: "index_dispensary_sources_on_slug", unique: true

  create_table "hashtags", force: :cascade do |t|
    t.string "name"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.boolean  "ancillary"
    t.string   "product_type"
    t.string   "slug"
    t.string   "description"
    t.boolean  "featured_product"
    t.string   "short_description"
    t.integer  "category_id"
    t.decimal  "year"
    t.decimal  "month"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alternate_names"
    t.string   "sub_category"
    t.string   "is_dom"
    t.decimal  "cbd"
    t.decimal  "cbn"
    t.decimal  "min_thc"
    t.decimal  "med_thc"
    t.decimal  "max_thc"
  end

  add_index "products", ["slug"], name: "index_products_on_slug", unique: true

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
    t.boolean  "active"
    t.string   "source_type"
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
    t.boolean  "product_state"
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

  create_table "vendor_products", force: :cascade do |t|
    t.integer  "vendor_id"
    t.integer  "product_id"
    t.decimal  "units_sold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "state_id"
    t.integer  "tier"
    t.string   "vendor_type"
    t.string   "address"
    t.decimal  "total_sales"
    t.string   "license_number"
    t.string   "ubi_number"
    t.string   "dba"
    t.string   "month_inc"
    t.integer  "year_inc"
    t.integer  "month_inc_num"
    t.float    "longitude"
    t.float    "latitude"
  end

  add_index "vendors", ["slug"], name: "index_vendors_on_slug", unique: true

end
