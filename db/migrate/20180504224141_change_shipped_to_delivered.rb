class ChangeShippedToDelivered < ActiveRecord::Migration
  def change
    remove_column :dispensary_source_orders, :shipped
    add_column :dispensary_source_orders, :delivered, :boolean
  end
end
