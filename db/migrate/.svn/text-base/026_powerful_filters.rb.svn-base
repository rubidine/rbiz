class PowerfulFilters < ActiveRecord::Migration
  def self.up
    add_column :tags, :hide_from_navigation, :boolean, :default=>false
    add_column :tags, :short_description, :string, :limit=>100
    add_column :tags, :full_description, :text
  end

  def self.down
    remove_column :tags, :hide_from_navigation
    remove_column :tags, :short_description
    remove_column :tags, :full_description
  end
end
