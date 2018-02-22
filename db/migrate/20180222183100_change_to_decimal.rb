class ChangeToDecimal < ActiveRecord::Migration
  def change
    remove_column :vendors, :linkedin_name
    remove_column :vendors, :twitter_name
    remove_column :vendors, :year_of_establishment
    remove_column :vendors, :specialization
    remove_column :vendors, :website
    remove_column :vendors, :facebook_link
    add_column :vendors, :tier, :integer
    add_column :vendors, :vendor_type, :string
    add_column :vendors, :address, :string
    add_column :vendors, :total_sales, :decimal
    add_column :vendors, :license_number, :string
    add_column :vendors, :ubi_number, :string
    add_column :vendors, :dba, :string
    add_column :vendors, :month_inc, :string
    add_column :vendors, :year_inc, :integer
    add_column :vendors, :month_inc_num, :integer
  end
end
