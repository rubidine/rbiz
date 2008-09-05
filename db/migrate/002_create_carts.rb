class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.column "customer_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "shipping_price", :integer # FIXED WIDTH
      t.column "tax_price", :integer
      t.column "total_price", :integer
      t.column "comments", :text
      t.column "shipping_address_id", :integer
      t.column "billing_address_id", :integer
      t.column "last_viewed", :timestamp
      t.column "status", :integer
    end
  end

  def self.down
    drop_table :carts
  end
end
