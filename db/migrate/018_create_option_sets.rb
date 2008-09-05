class CreateOptionSets < ActiveRecord::Migration
  def self.up
    create_table :option_sets do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :option_sets
  end
end
