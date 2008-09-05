class EnhanceCouponsWithLines < ActiveRecord::Migration
  def self.up
    add_column :coupons, :buy_this_many, :integer
    add_column :coupons, :get_this_many, :integer
    add_column :coupons, :double_line_only_once, :boolean, :default => false
    add_column :line_items, :coupon_id, :integer
  end

  def self.down
    remove_column :coupons, :buy_this_many
    remove_column :coupons, :get_this_many
    remove_column :coupons, :double_line_only_once
    remove_column :line_items, :coupon_id
  end
end
