class CouponsWithLines < ActiveRecord::Migration
  def self.up
    add_column :coupons, :double_line, :boolean
    add_column :line_items, :custom_double_line_id, :integer
  end

  def self.down
    remove_column :coupons, :double_line
    remove_column :line_items, :custom_double_line_id
  end
end
