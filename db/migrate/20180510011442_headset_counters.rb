class HeadsetCounters < ActiveRecord::Migration
  def change
    add_column :products, :headset_alltime_count, :integer, :default => 0
    add_column :products, :headset_monthly_count, :integer, :default => 0
    add_column :products, :headset_weekly_count, :integer, :default => 0
    add_column :products, :headset_daily_count, :integer, :default => 0
  end
end
