class DspOrder < ActiveRecord::Migration
  def change
    add_column :dsp_prices, :display_order, :integer
  end
end
