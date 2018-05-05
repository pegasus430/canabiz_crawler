class OrderFields < ActiveRecord::Migration
  def change
    remove_column :orders, :country
    remove_column :orders, :address
    add_column :orders, :street, :text
    add_column :orders, :zip_code, :text
  end
end
