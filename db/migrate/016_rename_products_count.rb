class RenameProductsCount < ActiveRecord::Migration
  def self.up
    rename_column :products, :children_count, :products_count
  end

  def self.down
    rename_column :products, :products_count, :children_count
  end
end
