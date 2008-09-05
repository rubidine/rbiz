class MarkLineItemAsSold < ActiveRecord::Migration
  def self.up
    add_column :line_items, :sold_at, :datetime
  end

  def self.down
    remove_column :line_items, :sold_at
  end
end
