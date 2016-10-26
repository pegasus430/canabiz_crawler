class SourceLogoChanges < ActiveRecord::Migration
  def change
    add_column :sources, :article_logo, :string
    add_column :sources, :sidebar_logo, :string
    remove_column :sources, :logo
  end
end
