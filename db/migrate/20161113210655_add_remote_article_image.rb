class AddRemoteArticleImage < ActiveRecord::Migration
  def change
      add_column :articles, :remote_image_url, :string
  end
end
