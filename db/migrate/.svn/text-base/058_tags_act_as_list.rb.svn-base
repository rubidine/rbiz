class TagsActAsList < ActiveRecord::Migration
  def self.up
    unless Tag.columns.detect{|x| x.name == 'position'}
      add_column :tags, :position, :integer
      TagSet.find(:all).each do |ts|
        ts.tags.find(:all).sort_by{|x| x.name.downcase}.each_with_index do |x,i|
          x.update_attribute(:position, i+1)
        end
      end
    end
  end

  def self.down
    remove_column :tags, :position
  end
end
