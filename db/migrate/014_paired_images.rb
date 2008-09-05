class PairedImages < ActiveRecord::Migration
  def self.up
    add_column :product_images, :twin_id, :integer
  end

  def self.down
    remove_column :product_images, :twin_id
  end
end
