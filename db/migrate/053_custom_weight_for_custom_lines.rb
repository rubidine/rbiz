class CustomWeightForCustomLines < ActiveRecord::Migration
  def self.up
    add_column :line_items, :custom_weight, :float
  end

  def self.down
    remove_column :line_items, :custom_weight
  end
end
