class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.string :email
      t.text :address
      t.string :city
      t.string :state
      t.string :country

      t.timestamps null: false
    end
  end
end
