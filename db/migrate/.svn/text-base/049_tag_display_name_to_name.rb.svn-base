class TagDisplayNameToName < ActiveRecord::Migration
  def self.up
    rename_column :tags, :display_name, :name
  end

  def self.down
    rename_column :tags, :name, :display_name
  end
end
