class LineItemCustomPriceRename < ActiveRecord::Migration
  def self.up
    rename_column :line_items, :custom_cost, :custom_price
  end

  def self.down
    rename_column :line_items, :custom_price, :custom_cost
  end
end
