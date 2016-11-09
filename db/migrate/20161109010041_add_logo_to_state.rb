class AddLogoToState < ActiveRecord::Migration
  def change
    add_column :states, :logo, :string
  end
end
