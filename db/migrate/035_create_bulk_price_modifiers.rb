class CreateBulkPriceModifiers < ActiveRecord::Migration
  def self.up
    create_table :bulk_price_modifiers do |t|
      t.column :product_id, :integer
      t.column :price_difference, :integer
      t.column :min_quantity, :integer
      t.column :max_quantity, :integer
    end
  end

  def self.down
    drop_table :bulk_price_modifiers
  end
end
