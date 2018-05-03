class DropHashtags < ActiveRecord::Migration
  def change
    drop_table :hashtags
  end
end
