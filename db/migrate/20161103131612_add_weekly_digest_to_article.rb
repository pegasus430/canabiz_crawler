class AddWeeklyDigestToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :include_in_digest, :boolean
  end
end
