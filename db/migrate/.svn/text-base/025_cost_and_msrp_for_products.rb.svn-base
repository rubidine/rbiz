class CostAndMsrpForProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :cost, :integer
    add_column :products, :msrp, :integer
  end

  def self.down
    remove_column :products, :cost
    remove_column :products, :msrp
  end
end
