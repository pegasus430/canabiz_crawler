class VendorLongLat < ActiveRecord::Migration
  def change
    add_column :vendors, :longitude, :float
    add_column :vendors, :latitude, :float
  end
end
