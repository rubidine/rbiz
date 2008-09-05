class CreateManufacturers < ActiveRecord::Migration
  def self.up
    create_table :manufacturers do |t|
      t.column "name", :string
      t.column "slug", :string
      t.column "description", :string
      t.column "image_path", :string
      t.column "image_alt", :string
      t.column "site_url", :string
      t.column "tag_id", :integer
      t.column "updated_at", :datetime
    end
  end

  def self.down
    drop_table :manufacturers
  end
end
