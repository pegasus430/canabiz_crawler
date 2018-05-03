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

ActiveRecord::Schema.define(version: 20180503002547) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "active_admin_managed_resources", force: :cascade do |t|
    t.string "class_name", null: false
    t.string "action",     null: false
    t.string "name"
  end

  add_index "active_admin_managed_resources", ["class_name", "action", "name"], name: "active_admin_managed_resources_index", unique: true

  create_table "active_admin_permissions", force: :cascade do |t|
    t.integer "managed_resource_id",                       null: false
    t.integer "role",                limit: 1, default: 0, null: false
    t.integer "state",               limit: 1, default: 0, null: false
  end

  add_index "active_admin_permissions", ["managed_resource_id", "role"], name: "active_admin_permissions_index", unique: true

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "role",                   limit: 1, default: 0,  null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

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

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer  "admin_user_id"
    t.boolean  "has_hypur",     default: false
    t.boolean  "has_payqwick",  default: false
  end

  add_index "dispensaries", ["slug"], name: "index_dispensaries_on_slug", unique: true

  create_table "dispensary_source_orders", force: :cascade do |t|
    t.integer  "dispensary_source_id"
    t.integer  "order_id"
    t.decimal  "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dispensary_source_products", force: :cascade do |t|
    t.integer  "dispensary_source_id"
    t.integer  "product_id"
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
    t.integer  "admin_user_id"
  end

  add_index "dispensary_sources", ["slug"], name: "index_dispensary_sources_on_slug", unique: true

  create_table "dsp_prices", force: :cascade do |t|
    t.integer "dispensary_source_product_id"
    t.decimal "price"
    t.string  "unit"
    t.integer "display_order"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.text     "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "phone"
    t.integer  "dispensary_source_id"
    t.integer  "dispensary_id"
  end

  create_table "product_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "dispensary_id"
    t.integer  "dsp_price_id"
    t.integer  "cart_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "quantity",                   default: 1
    t.integer  "order_id"
    t.integer  "dispensary_source_order_id"
    t.integer  "dispensary_source_id"
  end

  add_index "product_items", ["cart_id"], name: "index_product_items_on_cart_id"
  add_index "product_items", ["dispensary_id"], name: "index_product_items_on_dispensary_id"
  add_index "product_items", ["dsp_price_id"], name: "index_product_items_on_dsp_price_id"
  add_index "product_items", ["order_id"], name: "index_product_items_on_order_id"
  add_index "product_items", ["product_id"], name: "index_product_items_on_product_id"

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.string   "product_type"
    t.string   "slug"
    t.string   "description"
    t.boolean  "featured_product"
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
    t.integer  "dsp_count"
    t.integer  "state_id"
  end

  add_index "products", ["slug"], name: "index_products_on_slug", unique: true

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
