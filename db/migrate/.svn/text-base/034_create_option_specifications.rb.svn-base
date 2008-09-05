class CreateOptionSpecifications < ActiveRecord::Migration
  def self.up
    create_table :option_specifications do |t|
      t.column :option_text, :text
      t.column :option_id, :integer
      t.column :line_item_id, :integer
    end
  end

  def self.down
    drop_table :option_specifications
  end
end
