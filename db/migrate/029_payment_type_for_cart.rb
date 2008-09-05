class PaymentTypeForCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :payment_type, :string
  end

  def self.down
    remove_column :carts, :payment_type
  end
end
