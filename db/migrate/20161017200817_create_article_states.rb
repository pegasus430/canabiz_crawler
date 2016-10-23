class CreateArticleStates < ActiveRecord::Migration
    def change
        create_table :article_states do |t|
            t.integer :article_id
            t.integer :state_id
            t.timestamps
        end
    end
end
