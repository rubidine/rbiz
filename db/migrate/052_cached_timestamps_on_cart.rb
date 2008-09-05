class CachedTimestampsOnCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :shipping_computed_at, :timestamp
  end

  def self.down
    remove_column :carts, :shipping_computed_at
  end
end
