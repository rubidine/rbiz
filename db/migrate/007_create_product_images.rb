class CreateProductImages < ActiveRecord::Migration
  def self.up
    create_table :product_images do |t|
      t.column "product_id", :integer
      t.column "image_path", :string
      t.column "image_alt", :string
      t.column "thumbnail", :boolean
      t.column "position", :int # ACTS AS LIST
    end
  end

  def self.down
    drop_table :product_images
  end
end
