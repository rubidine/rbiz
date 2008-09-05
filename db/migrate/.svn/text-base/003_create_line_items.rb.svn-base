class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.column "product_id", :integer
      t.column "quantity", :integer
      t.column "cart_id", :integer
    end
  end

  def self.down
    drop_table :line_items
  end
end
