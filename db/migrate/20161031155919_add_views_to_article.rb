class AddViewsToArticle < ActiveRecord::Migration
  def change
      add_column :articles, :num_views, :integer
  end
end
