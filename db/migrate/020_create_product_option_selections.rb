class CreateProductOptionSelections < ActiveRecord::Migration
  def self.up
    create_table :product_option_selections do |t|
      t.column :product_id, :integer
      t.column :quantity, :integer
      t.column :price_adjustment, :integer
    end
  end

  def self.down
    drop_table :product_option_selections
  end
end
