class ZipFieldOnOrder < ActiveRecord::Migration
  def change
    add_column :orders, :zip_code, :text
  end
end
