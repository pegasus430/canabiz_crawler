class ReverseFieldRemoval < ActiveRecord::Migration
  def change
    add_column :states, :product_state, :boolean
  end
end
