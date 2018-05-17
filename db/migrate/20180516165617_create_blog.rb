class CreateBlog < ActiveRecord::Migration
  def change
    create_table :blog do |t|
      t.string :title
      t.string :body
      t.timestamps
    end
  end
end
