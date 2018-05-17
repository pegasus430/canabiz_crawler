class TimestampsToNewTables < ActiveRecord::Migration
  def change
    add_timestamps :product_states, default: DateTime.now
    add_timestamps :vendor_states, default: DateTime.now
    # add_column :product_states, :created_at, :datetime, null: false
    # add_column :product_states, :updated_at, :datetime, null: false
    # add_column :vendor_states, :created_at, :datetime, null: false
    # add_column :vendor_states, :updated_at, :datetime, null: false
  end
end
