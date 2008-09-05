class TaxExemptProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :tax_exempt, :boolean
    add_column :line_items, :custom_tax_exempt, :boolean
  end

  def self.down
  end
end
