class DecoratedCartConfig < ActiveRecord::Migration
  def self.up
    unless CartConfig.columns.detect{|x| x.name.to_s == 'basic_type'}
      add_column :cart_configs, :basic_type, :string
      add_column :cart_configs, :hide_from_user, :boolean
    end
  end

  def self.down
    remove_column :cart_configs, :basic_type
    remove_column :cart_configs, :hide_from_user
  end
end
