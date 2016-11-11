class CreateSortOptions < ActiveRecord::Migration
  def change
    create_table :sort_options do |t|
      t.string :name
      t.string :query
      t.string :direction
      t.integer :num_clicks
    end
  end
end
