class ProductTagJoin < ActiveRecord::Migration
  def self.up
    create_table :products_tags, :id=>false do |t|
      t.column :tag_id, :int
      t.column :product_id, :int
    end
    ActiveRecord::Base.connection.execute(
      "INSERT INTO products_tags VALUES(1,1)"
    )
  end

  def self.down
    drop_table :products_tags
  end
end
