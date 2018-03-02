class CreateDspPrices < ActiveRecord::Migration
  def change
    create_table :dsp_prices do |t|
      t.integer :dispensary_source_product_id
      t.decimal :price
      t.string :unit
    end
  end
end
