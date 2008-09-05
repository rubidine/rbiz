class CreateQuantityReservations < ActiveRecord::Migration
  def self.up
    create_table :quantity_reservations do |t|
      t.integer :cart_id, :line_item_id, :reserved_object_id
      t.string :reserved_object_type
      t.timestamps
    end

    add_column :line_items, :quantity_reservations_count, :integer, :default => 0

    Product.update_all({:quantity_committed => 0})
    ProductOptionSelection.update_all({:quantity_committed => 0})

    LineItem.find(:all, :include => :cart, :conditions => {:'carts.sold_at' => nil}).each do |li|
      li.quantity.times do
        QuantityReservation.create!(:line_item => li, :reserved_object => (li.product_option_selection || li.product))
      end
    end
  end

  def self.down
  end
end
