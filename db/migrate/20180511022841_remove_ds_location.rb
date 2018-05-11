class RemoveDsLocation < ActiveRecord::Migration
  def change
    remove_column :dispensary_sources, :location
  end
end
