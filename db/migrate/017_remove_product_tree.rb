class RemoveProductTree < ActiveRecord::Migration
  def self.up
    remove_column :products, :parent_id
    remove_column :products, :products_count
    remove_column :products, :container_only
  end

  def self.down
    add_column :products, :parent_id, :integer
    add_column :products, :products_count, :integer
    add_column :products, :container_only, :boolean
  end
end
