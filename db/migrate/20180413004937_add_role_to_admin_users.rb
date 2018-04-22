class AddRoleToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :integer, null: false, limit: 1, default: 0
  end
end
