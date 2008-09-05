class SkuOverrideOnOption < ActiveRecord::Migration
  def self.up
    add_column :options, :sku_extension, :string
    add_column :option_sets, :sku_extension_order, :integer
  end

  def self.down
    remove_column :options, :sku_extension
    remove_column :option_sets, :sku_extension_order
  end
end
