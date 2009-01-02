class RenameProductOptionSelectionVariation < ActiveRecord::Migration
  def self.up
    rename_table :product_option_selections, :variations
    rename_table :options_product_option_selections, :options_variations
    rename_column :options_variations, :product_option_selection_id, :variation_id
  end

  def self.down
    rename_column :options_variations, :variation_id, :product_option_selection_id
    rename_table :variations, :product_option_selections
    rename_table :options_variations, :options_product_option_selections
  end
end
