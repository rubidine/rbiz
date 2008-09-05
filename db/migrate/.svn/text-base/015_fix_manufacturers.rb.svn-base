class FixManufacturers < ActiveRecord::Migration
  def self.up
    add_column :products, :manufacturer_id, :integer
    remove_column :manufacturers, :tag_id
  end

  def self.down
    add_column :manufacturers, :tag_id, :integer
    remove_column :products, :manufacturer_id
  end
end
