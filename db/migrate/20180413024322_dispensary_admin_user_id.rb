class DispensaryAdminUserId < ActiveRecord::Migration
  def change
    add_column :dispensaries, :admin_user_id, :integer
  end
end
