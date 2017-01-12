class UserArticleTimestamps < ActiveRecord::Migration
  def change
    add_column :user_articles, :created_at, :datetime
    add_column :user_articles, :updated_at, :datetime
  end
end
