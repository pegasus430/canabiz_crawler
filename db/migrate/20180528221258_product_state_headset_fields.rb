class ProductStateHeadsetFields < ActiveRecord::Migration
  def change
    add_column :product_states, :headset_alltime_count, :integer, :default => 0
    add_column :product_states, :headset_monthly_count, :integer, :default => 0
    add_column :product_states, :headset_weekly_count, :integer,  :default => 0
    add_column :product_states, :headset_daily_count, :integer,   :default => 0
  end
end
