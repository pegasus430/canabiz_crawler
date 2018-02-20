class RemainingFields < ActiveRecord::Migration
  def change
    add_column :average_prices, :display_order, :decimal
    add_column :vendors, :state_id, :integer
  end
end
