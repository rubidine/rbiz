class TagSetsCacheTagCount < ActiveRecord::Migration
  def self.up
    add_column :tag_sets, :tags_count, :integer, :default => 0
    TagSet.find(:all).each do |ts|
      ts.update_attribute(:tags_count, ts.tags.count)
    end
  end

  def self.down
    remove_column :tag_sets, :tags_count
  end
end
