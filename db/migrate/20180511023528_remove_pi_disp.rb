class RemovePiDisp < ActiveRecord::Migration
  def change
    remove_column :product_items, :dispensary_id
  end
end
