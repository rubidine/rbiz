class NullableCustomerIdOnCart < ActiveRecord::Migration
  def self.up
    change_column :carts, :customer_id, :integer, :null => true, :default => nil
  end

  def self.down
  end
end
