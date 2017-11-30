class DropSortOptions < ActiveRecord::Migration
  def change
    drop_table :sort_options
  end
end
