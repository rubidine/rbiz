class ExtraDescriptionFields < ActiveRecord::Migration
  def self.up
    add_column :tag_sets, :description, :text
    add_column :tag_sets, :short_description, :string
    add_column :products, :short_description, :string
  end

  def self.down
    remove_column :tag_sets, :description
    remove_column :tag_sets, :short_description
    remove_column :products, :short_description
  end
end
