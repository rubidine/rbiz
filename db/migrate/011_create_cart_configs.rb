class CreateCartConfigs < ActiveRecord::Migration
  def self.up
    create_table :cart_configs do |t|
      t.column :scope, :string
      t.column :name, :string
      t.column :value, :text
    end
  end

  def self.down
    drop_table :cart_configs
  end
end
