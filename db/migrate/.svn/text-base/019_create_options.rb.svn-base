class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.column :option_set_id, :integer
      t.column :name, :string
    end
  end

  def self.down
    drop_table :options
  end
end
