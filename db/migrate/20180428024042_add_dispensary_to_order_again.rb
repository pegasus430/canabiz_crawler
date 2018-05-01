class AddDispensaryToOrderAgain < ActiveRecord::Migration
  def change
    add_column :orders, :dispensary_id, :integer
  end
end
