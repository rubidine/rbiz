class RemoveBulkPriceModifierIdFromLineItems < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :bulk_price_modifier_id
  end

  def self.down
    add_column :line_items, :bulk_price_modifier_id, :integer
  end
end
