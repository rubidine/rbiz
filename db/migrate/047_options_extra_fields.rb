class OptionsExtraFields < ActiveRecord::Migration
  def self.up
    add_column :options, :weight_adjustment, :float
    add_column :options, :short_description, :string
  end

  def self.down
  end
end
