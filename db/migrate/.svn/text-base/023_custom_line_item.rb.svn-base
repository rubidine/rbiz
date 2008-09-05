class CustomLineItem < ActiveRecord::Migration
  def self.up
    add_column :line_items, :custom_cost, :integer
    add_column :line_items, :custom_description, :string
  end

  def self.down
    remove_column :line_items, :custom_cost
    remove_column :line_items, :custom_description
  end
end
