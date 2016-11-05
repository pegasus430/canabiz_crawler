class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string   :name
    end
    
    create_table :source_hashtags do |t|
      t.integer   :source_id
      t.integer   :hashtag_id
    end
  end
end
