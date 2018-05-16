class ProductVendorState < ActiveRecord::Migration
  def change
    create_table :vendor_states do |t|
      t.integer :vendor_id
      t.integer :state_id
    end
    
    create_table :product_states do |t|
      t.integer :product_id
      t.integer :state_id
    end
  end
end
