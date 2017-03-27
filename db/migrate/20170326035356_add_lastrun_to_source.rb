class AddLastrunToSource < ActiveRecord::Migration
  def change
    add_column :sources, :last_run, :datetime
  end
end
