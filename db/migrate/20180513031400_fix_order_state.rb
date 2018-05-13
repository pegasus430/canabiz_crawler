class FixOrderState < ActiveRecord::Migration
  def change
    remove_column :orders, :state
    add_column :orders, :state_id, :integer
  end
end
