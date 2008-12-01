class AddCountryToAddress < ActiveRecord::Migration
  def self.up
    change_column :addresses, :state, :string, :limit=>3
    add_column :addresses, :country, :string, :limit=>2
  end
  def self.down
    remove_column :addresses, :country
  end
end
