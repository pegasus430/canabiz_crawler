class RemoveOrderFields < ActiveRecord::Migration
  def change
    remove_column :orders, :dispensary_id
    remove_column :orders, :dispensary_source_id
  end
end
