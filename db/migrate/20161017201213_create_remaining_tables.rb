class CreateRemainingTables < ActiveRecord::Migration
    def change
        
        create_table :categories do |t|
            t.string  :name
            t.string  :keywords
            t.boolean :active
            t.timestamps
        end
        
        create_table :sources do |t|
            t.string :name
            t.string :url
            t.string :logo
            t.timestamps
        end
        
        create_table :states do |t|
            t.string  :name
            t.string  :abbreviation
            t.string  :keywords
            t.timestamps
        end
        
        create_table :users do |t|
            t.string   :username
            t.string   :email
            t.string   :password_digest
            t.boolean  :admin
            t.timestamps
        end
        
        create_table :user_states do |t|
            t.integer :user_id
            t.integer :state_id
            t.timestamps
        end
        
        create_table :user_sources do |t|
            t.integer :user_id
            t.integer :source_id
            t.timestamps
        end
        
        create_table :user_categories do |t|
            t.integer :user_id
            t.integer :category_id
            t.timestamps
        end
    end
end
