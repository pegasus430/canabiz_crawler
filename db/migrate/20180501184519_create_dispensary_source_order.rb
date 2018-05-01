class CreateDispensarySourceOrder < ActiveRecord::Migration
  def change
    create_table :dispensary_source_orders do |t|
      t.integer :dispensary_source_id
      t.integer :order_id
      t.decimal :total_price
      t.timestamps
    end
    
    add_column :product_items, :dispensary_source_order_id, :integer
  end
end
