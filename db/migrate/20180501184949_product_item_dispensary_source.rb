class ProductItemDispensarySource < ActiveRecord::Migration
  def change
    add_column :product_items, :dispensary_source_id, :integer
  end
end
