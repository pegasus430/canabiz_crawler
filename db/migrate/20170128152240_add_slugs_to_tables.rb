class AddSlugsToTables < ActiveRecord::Migration
    def change
        add_column :states, :slug, :string
        add_index :states, :slug, unique: true
        
        add_column :categories, :slug, :string
        add_index :categories, :slug, unique: true
        
        add_column :articles, :slug, :string
        add_index :articles, :slug, unique: true
        
        add_column :sources, :slug, :string
        add_index :sources, :slug, unique: true
        
        add_column :users, :slug, :string
        add_index :users, :slug, unique: true
    end
end
