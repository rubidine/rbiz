class OptionsOnLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :product_option_selection_id, :integer
  end

  def self.down
    remove_column :line_items, :product_option_selection_id
  end
end
