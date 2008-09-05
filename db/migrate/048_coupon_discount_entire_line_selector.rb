class CouponDiscountEntireLineSelector < ActiveRecord::Migration
  def self.up
    add_column :coupons, :discount_entire_line, :boolean, :default => false
  end

  def self.down
    remove_column :coupons, :discount_entire_line
  end
end
