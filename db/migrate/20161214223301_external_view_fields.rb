class ExternalViewFields < ActiveRecord::Migration
  def change
      add_column :articles, :external_visits, :integer, :default => 0
      add_column :sources, :external_article_visits, :integer, :default => 0
  end
end
