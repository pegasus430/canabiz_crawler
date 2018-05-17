class ChangeBlogBodyToText < ActiveRecord::Migration
  def change
    remove_column :blog, :body
    add_column :blog, :body, :text
  end
end
