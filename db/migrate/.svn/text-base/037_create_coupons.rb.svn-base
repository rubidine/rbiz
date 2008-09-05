class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.column :effective_on, :date
      t.column :ineffective_on, :date
      t.column :code, :string
      t.column :requires_all, :boolean
      t.column :requires_any, :boolean
      t.column :requires_distinct_count, :integer
      t.column :requires_total_count, :integer
      t.column :requires_minimum_purchase, :integer
      t.column :applies_all_required, :boolean
      t.column :applies_all_associated, :boolean
      t.column :applies_total, :boolean
      t.column :applies_max_required, :boolean
      t.column :applies_max_associated, :boolean
      t.column :applies_max_equal_lesser_required, :boolean
      t.column :applies_max_equal_lesser_associated, :boolean
      t.column :applies_max_equal_lesser_other, :boolean
      t.column :applies_shipping, :boolean
      t.column :discount_percent, :integer
      t.column :discount_price, :integer
    end

    create_table :carts_coupons, :id => false do |t|
      t.column :cart_id, :integer
      t.column :coupon_id, :integer
    end

    create_table :coupons_required_products, :id => false do |t|
      t.column :coupon_id, :integer
      t.column :product_id, :integer
    end

    create_table :coupons_associated_products, :id => false do |t|
      t.column :coupon_id, :integer
      t.column :product_id, :integer
    end
  end

  def self.down
    drop_table :coupons
    drop_table :carts_coupons
    drop_table :coupons_required_products
    drop_table :coupons_associated_products
  end
end
