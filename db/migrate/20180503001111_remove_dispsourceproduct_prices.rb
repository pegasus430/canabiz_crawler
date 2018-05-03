class RemoveDispsourceproductPrices < ActiveRecord::Migration
  def change
    remove_column :dispensary_source_products, :image
    remove_column :dispensary_source_products, :price
    remove_column :dispensary_source_products, :price_gram
    remove_column :dispensary_source_products, :price_eighth
    remove_column :dispensary_source_products, :price_quarter
    remove_column :dispensary_source_products, :price_half_gram
    remove_column :dispensary_source_products, :price_two_grams
    remove_column :dispensary_source_products, :price_half_ounce
    remove_column :dispensary_source_products, :price_ounce
    remove_column :dispensary_source_products, :price_80mg
    remove_column :dispensary_source_products, :price_160mg
    remove_column :dispensary_source_products, :price_180mg
    remove_column :dispensary_source_products, :price_100mg
    remove_column :dispensary_source_products, :price_40mg
    remove_column :dispensary_source_products, :price_25mg
    remove_column :dispensary_source_products, :price_150mg
    remove_column :dispensary_source_products, :price_10mg
    remove_column :dispensary_source_products, :price_50mg
    remove_column :dispensary_source_products, :price_240mg
    remove_column :dispensary_source_products, :price_1mg
    remove_column :dispensary_source_products, :price_2_5mg
    remove_column :dispensary_source_products, :one
    
    remove_column :products, :ancillary
    remove_column :products, :short_description
    
    drop_table :source_hashtags
  end
end

