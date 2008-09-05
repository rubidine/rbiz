class PaymentInfoAndErrorMessageInDatabase < ActiveRecord::Migration
  def self.up
    add_column :carts, :error_message, :string
    add_column :carts, :payment_info, :string
  end

  def self.down
    remove_column :carts, :error_message
    remove_column :carts, :payment_info
  end
end
