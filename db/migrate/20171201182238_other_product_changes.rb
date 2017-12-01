class OtherProductChanges < ActiveRecord::Migration
  def change
      add_column :categories, :category_type, :string
      
      create_table :dispensaries do |t|
          t.string   :name
          t.string   :image
          t.string   :location
          t.string   :city
          t.string   :about
          t.string   :slug
          t.integer  :state_id
          t.float    :latitude
          t.float    :longitude
          t.timestamps 
      end
      
      add_index :dispensaries, :slug, unique: true
      
      create_table :dispensary_source_products do |t|
          t.integer  :dispensary_source_id
          t.integer  :product_id
          t.string   :image
          t.decimal  :price
          t.decimal  :price_gram
          t.decimal  :price_eighth
          t.decimal  :price_quarter
          t.decimal  :price_half_gram
          t.decimal  :price_two_grams
          t.decimal  :price_half_ounce
          t.decimal  :price_ounce
          t.decimal  :price_80mg
          t.decimal  :price_160mg
          t.decimal  :price_180mg
          t.decimal  :price_100mg
          t.decimal  :price_40mg
          t.decimal  :price_25mg
          t.decimal  :price_150mg
          t.decimal  :price_10mg
          t.decimal  :price_50mg
          t.decimal  :price_240mg
          t.decimal  :price_1mg
          t.decimal  :price_2_5mg
          t.decimal  :one
          t.timestamps
      end
      
      create_table :dispensary_sources do |t|
          t.integer  :dispensary_id
          t.integer  :source_id
          t.integer  :state_id
          t.string   :name
          t.string   :slug
          t.string   :image
          t.string   :location
          t.string   :city
          t.float    :latitude
          t.float    :longitude
          t.string   :source_rating
          t.string   :source_url
          t.time     :monday_open_time
          t.time     :tuesday_open_time
          t.time     :wednesday_open_time
          t.time     :thursday_open_time
          t.time     :friday_open_time
          t.time     :saturday_open_time
          t.time     :sunday_open_time
          t.time     :monday_close_time
          t.time     :tuesday_close_time
          t.time     :wednesday_close_time
          t.time     :thursday_close_time
          t.time     :friday_close_time
          t.time     :saturday_close_time
          t.time     :sunday_close_time
          t.string   :facebook
          t.string   :instagram
          t.string   :twitter
          t.string   :website
          t.string   :email
          t.string   :phone
          t.integer  :min_age
          t.datetime :last_menu_update
          t.string   :street
          t.string   :zip_code
          t.timestamps
      end
      
      add_index :dispensary_sources, :slug, unique: true
      
      create_table :products do |t|
          t.string   :name
          t.string   :image
          t.boolean  :ancillary
          t.string   :product_type
          t.string   :slug
          t.string   :description
          t.boolean  :featured_product
          t.string   :short_description
          t.integer  :category_id
          t.decimal  :year
          t.decimal  :month
          t.timestamps
      end
      
      add_index :products, :slug, unique: true
      
      add_column :sources, :source_type, :string
      
      add_column :states, :product_state, :boolean
      
      create_table :vendor_products do |t|
          t.integer :vendor_id
          t.integer :product_id
          t.decimal :units_sold
          t.timestamps
      end
      
      create_table :vendors do |t|
          t.string  :slug
          t.string  :name
          t.string  :description
          t.string  :linkedin_name
          t.string  :twitter_name
          t.integer :year_of_establishment
          t.string  :specialization
          t.string  :website
          t.string  :facebook_link
          t.timestamps
      end
      
      add_index :vendors, :slug, unique: true
  end
end
