class AddSlugToBlog < ActiveRecord::Migration
  def change
    add_column :blog, :slug, :string
    add_index :blog, :slug, unique: true
  end
end
