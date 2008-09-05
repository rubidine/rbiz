class ProductOptionSelectionProductOptionJoinTable < ActiveRecord::Migration
  def self.up
    create_table :options_product_option_selections, :force=>true, :id=>false do |t|
      t.column :option_id, :integer
      t.column :product_option_selection_id, :integer
    end
  end

  def self.down
    drop_table :options_product_option_selections
  end
end
