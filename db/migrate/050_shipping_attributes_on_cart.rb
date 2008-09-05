class ShippingAttributesOnCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :freight_shipping, :boolean
    add_column :carts, :shipping_error, :boolean
    add_column :carts, :fulfilled_at, :timestamp
    add_column :carts, :sold_at, :timestamp
    add_column :carts, :billing_error, :boolean
    add_column :carts, :fulfillment_error, :boolean

    Cart.find(:all, :conditions => ['status = ?', 3]).each do |x|
      x.update_attribute(:sold_at, x.updated_at)
    end
  end

  def self.down
    remove_column :carts, :freight_shipping
    remove_column :carts, :shipping_error
    remove_column :carts, :fulfilled_at
    remove_column :carts, :sold_at
    remove_column :carts, :billing_error
    remove_column :carts, :fulfillment_error
  end
end
