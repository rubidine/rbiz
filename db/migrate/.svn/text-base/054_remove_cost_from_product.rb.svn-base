class RemoveCostFromProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :cost
    remove_column :products, :width
    remove_column :products, :height
    remove_column :products, :depth
    rename_column :products, :shipping, :extra_shipping
  end

  def self.down
    add_column :products, :cost, :integer
    add_column :products, :width, :integer
    add_column :products, :height, :integer
    add_column :products, :depth, :integer
    rename_column :products, :extra_shipping, :shipping
  end
end
