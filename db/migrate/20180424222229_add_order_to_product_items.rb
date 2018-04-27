class AddOrderToProductItems < ActiveRecord::Migration
  def change
    add_reference :product_items, :order, index: true, foreign_key: true
  end
end
