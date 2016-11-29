class SetNumViewsDefault < ActiveRecord::Migration
  def change
    change_column :articles, :num_views, :integer, :default => 0
  end
end
