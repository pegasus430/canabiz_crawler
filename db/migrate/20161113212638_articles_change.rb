class ArticlesChange < ActiveRecord::Migration
  def change
    add_column :articles, :remote_image_url, :string
  end
end
