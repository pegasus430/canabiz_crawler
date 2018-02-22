class ChangeToDecimal < ActiveRecord::Migration
  def change
    change_column :vendors, :total_sales, :decimal
  end
end
