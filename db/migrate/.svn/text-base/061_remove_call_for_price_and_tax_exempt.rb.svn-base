class RemoveCallForPriceAndTaxExempt < ActiveRecord::Migration
  def self.up
    remove_column :products, :call_for_price
    remove_column :products, :tax_exempt
    remove_column :line_items, :custom_tax_exempt
  end

  def self.down
    add_column :products, :call_for_price, :boolean
    add_column :products, :tax_exempt, :boolean
    add_column :line_items, :custom_tax_exempt, :boolean
  end
end
