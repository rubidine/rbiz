class OptionSetsProductsJoin < ActiveRecord::Migration
  def self.up
    create_table :option_sets_products, :force=>true, :id=>false do |t|
      t.column :product_id, :integer
      t.column :option_set_id, :integer
    end
  end

  def self.down
    drop_table :option_sets_products
  end
end
