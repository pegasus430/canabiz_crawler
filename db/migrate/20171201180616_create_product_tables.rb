class CreateProductTables < ActiveRecord::Migration
  def change
      create_table :average_prices do |t|
        t.integer :product_id
        t.decimal :average_price
        t.string  :average_price_unit
        t.decimal :units_sold
        t.timestamps
      end
  end
end
