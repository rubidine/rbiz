class AddTagSetToTagActivation < ActiveRecord::Migration
  def self.up
    ov = Product.find(:all).inject({}){|m,x| m.merge(x => x.tags)}
    p ov

    drop_table :products_tags

    create_table :products_tags do |t|
      t.column :product_id, :integer
      t.column :tag_id, :integer
      t.column :tag_set_id, :integer
    end

    ov.each do |p, tt|
      tt.each do |t|
        TagActivation.create!(:product => p, :tag => t)
      end
    end

  end

  def self.down
    remove_column :products_tags, :tag_set_id
    remove_column :products_tags, :id
  end
end
