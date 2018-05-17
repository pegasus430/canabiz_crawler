class RemoveProductState < ActiveRecord::Migration
  def change
    remove_column :states, :product_state
    add_column :states, :has_products, :boolean
  end
end
