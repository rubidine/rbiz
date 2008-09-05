class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.column "display_name", :string, :limit=>150
      t.column "street", :string, :limit=>150
      t.column "city", :string, :limit=>150
      t.column "state", :string, :limit=>2
      t.column "zip", :string, :limit=>12
      t.column "created_at", :timestamp
      t.column "customer_id", :integer
    end
  end

  def self.down
    drop_table :addresses
  end
end
