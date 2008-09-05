class TagsetSlug < ActiveRecord::Migration
  def self.up
    add_column :tag_sets, :slug, :string
    TagSet.find(:all).each do |t|
      t.slug = t.name.downcase.gsub(/[^\w\s]/, '').gsub(/\s+/, '-')
      t.save
    end
  end

  def self.down
    remove_column :tag_sets, :slug
  end
end
