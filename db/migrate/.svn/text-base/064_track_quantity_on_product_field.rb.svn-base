class TrackQuantityOnProductField < ActiveRecord::Migration
  def self.up
    add_column :product_option_selections, :track_quantity_on_product, :boolean, :default => false
  end

  def self.down
    remove_column :product_option_selections, :track_quantity_on_product
  end
end
