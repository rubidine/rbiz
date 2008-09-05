class ManufacturersToTags < ActiveRecord::Migration
  def self.up
    if defined?(Manufacturer)
      ts = TagSet.find_or_create_by_name('manufacturer')
      Manufacturer.find(:all).each do |m|
        pp = m.products
        desc = m.description
        if m.image_path
          desc = "#{desc}<img src=\"#{m.image_path}\" alt=\"#{m.image_alt}\"/>"
        end
        if m.site_url
          desc = "#{desc}<a href=\"#{m.site_url}\">Visit #{m.name} at #{m.site_url}</a>"
        end
        t = Tag.create(
          :display_name => m.name,
          :slug => m.slug,
          :tag_set_id => ts.id,
          :full_description => desc
        )
        raise t.errors.full_messages.join("\n") if t.new_record?
        m.destroy
        pp.tags << t
      end
    end if defined?(Manufacturer)

    remove_column :products, :manufacturer_id
    drop_table :manufacturers
  end

  def self.down
    create_table "manufacturers", :force => true do |t|
      t.column "name",        :string
      t.column "slug",        :string
      t.column "description", :string
      t.column "image_path",  :string
      t.column "image_alt",   :string
      t.column "site_url",    :string
      t.column "updated_at",  :datetime
    end
    add_column :products, :manufacturer_id, :integer
  end
end
