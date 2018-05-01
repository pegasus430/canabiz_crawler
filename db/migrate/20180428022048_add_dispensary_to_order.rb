class AddDispensaryToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :dispensary_source_id, :integer
  end
end
