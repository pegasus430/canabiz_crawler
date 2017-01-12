class CreateUserArticles < ActiveRecord::Migration
  def change
    create_table :user_articles do |t|
      t.integer :article_id
      t.integer :user_id
      t.boolean :saved
      t.boolean :viewed_internally
      t.boolean :viewed_externally
    end
  end
end
