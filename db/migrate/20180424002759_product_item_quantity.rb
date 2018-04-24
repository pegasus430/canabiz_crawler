class ProductItemQuantity < ActiveRecord::Migration
  def change
    add_column :product_items, :quantity, :integer, default: 1
  end
end
