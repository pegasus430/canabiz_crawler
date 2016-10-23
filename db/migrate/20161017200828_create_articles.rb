class CreateArticles < ActiveRecord::Migration
    def change
        create_table :articles do |t|
            t.string   :title
            t.string   :abstract
            t.string   :image
            t.string   :body
            t.datetime :date
            t.string   :web_url
            t.integer  :source_id
            t.timestamps
        end
    end
end
