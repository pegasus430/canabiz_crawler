class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :dispensary_id
      t.string :name
      t.decimal :discount
      t.string :deal_type
      t.boolean :top_deal
      t.integer :min_age
      t.string   :image
      t.timestamps
    end
  end
end
