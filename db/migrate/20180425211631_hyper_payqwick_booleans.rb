class HyperPayqwickBooleans < ActiveRecord::Migration
  def change
    add_column :dispensaries, :has_hypur, :boolean, default: false
    add_column :dispensaries, :has_payqwick, :boolean, default: false
  end
end
