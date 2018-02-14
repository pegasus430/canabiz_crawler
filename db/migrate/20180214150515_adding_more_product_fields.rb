class AddingMoreProductFields < ActiveRecord::Migration
  def change
    add_column :products, :alternate_names, :string
    add_column :products, :sub_category, :string
    add_column :products, :is_dom, :string
    add_column :products, :cbd, :decimal
    add_column :products, :cbn, :decimal
    add_column :products, :min_thc, :decimal
    add_column :products, :med_thc, :decimal
    add_column :products, :max_thc, :decimal
  end
end
