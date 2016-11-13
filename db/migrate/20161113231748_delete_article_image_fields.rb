class DeleteArticleImageFields < ActiveRecord::Migration
  def change
    remove_column :articles, :remote_file_url
  end
end
