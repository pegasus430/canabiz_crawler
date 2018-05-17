class ChangeUnitToBeIntegerInDspPrices < ActiveRecord::Migration
  def change
    change_column :dsp_prices, :unit, :integer
  end
end
