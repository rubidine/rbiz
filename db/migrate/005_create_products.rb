class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :parent_id, :integer # ACTS AS TREE
      t.column :children_count, :integer # ACTS AS TREE
      t.column :sku, :string
      t.column :weight, :float # POUNDS
      t.column :width, :float # INCHES
      t.column :height, :float
      t.column :depth, :float
      t.column :price, :int # FIXED WIDTH
      t.column :shipping, :int # FIXED WIDTH
      t.column :effective_on, :date
      t.column :ineffective_on, :date
      t.column :quantity, :int
      t.column :default_thumbnail_id, :int
      t.column :default_image_id, :int
      t.column :featured, :boolean
      t.column :updated_at, :timestamp
      t.column :slug, :string
      t.column :container_only, :boolean # ONLY A CONTAINER FOR CHILDREN
    end

  end

  def self.down
    drop_table :products
  end
end
