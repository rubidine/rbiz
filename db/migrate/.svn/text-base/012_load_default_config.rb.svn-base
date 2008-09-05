class LoadDefaultConfig < ActiveRecord::Migration
  def self.up
    add_column :cart_configs, :basic_type, :string
    add_column :cart_configs, :hide_from_user, :boolean
    CartConfig.load File.read(File.join(File.dirname(__FILE__), '..','..', 'config', 'default_cart_config.yml'))
  end

  def self.down
    CartConfig.delete_all
    remove_column :cart_configs, :basic_type
    remove_column :cart_configs, :hide_from_user
  end
end
