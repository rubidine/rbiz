class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column "slug", :string, :limit => 100
      t.column "display_name", :string, :limit => 150
      t.column "tag_set_id", :integer
    end
  end

  def self.down
    drop_table :tags
  end
end
