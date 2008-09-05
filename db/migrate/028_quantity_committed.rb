class QuantityCommitted < ActiveRecord::Migration
  def self.up
    add_column :products, :quantity_committed, :integer, :default=>0
    add_column :product_option_selections, :quantity_committed, :integer, :default=>0
  end

  def self.down
    remove_column :products, :quantity_committed
    remove_column :product_option_selections, :quantity_committed
  end
end
