class DispensarySourceAdmin < ActiveRecord::Migration
  def change
    add_column :dispensary_sources, :admin_user_id, :integer
  end
end
