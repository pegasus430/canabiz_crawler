class CreateProductItems < ActiveRecord::Migration
  def change
    create_table :product_items do |t|
      t.references :product, index: true, foreign_key: true
      t.references :dispensary, index: true, foreign_key: true
      t.references :dsp_price, index: true, foreign_key: true
      t.belongs_to :cart, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
