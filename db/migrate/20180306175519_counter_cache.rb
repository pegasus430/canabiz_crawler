class CounterCache < ActiveRecord::Migration
  def change
    add_column :products, :dsp_count, :integer
  end
end
