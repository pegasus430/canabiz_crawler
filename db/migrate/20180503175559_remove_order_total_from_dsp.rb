class RemoveOrderTotalFromDsp < ActiveRecord::Migration
  def change
    remove_column :dispensary_source_orders, :total_price
    add_column :dispensary_source_orders, :shipped, :boolean
    add_column :dispensary_source_orders, :picked_up, :boolean
  end
end
