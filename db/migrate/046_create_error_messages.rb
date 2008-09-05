class CreateErrorMessages < ActiveRecord::Migration
  def self.up
    create_table :error_messages do |t|
      t.column :scope, :string
      t.column :message, :string
      t.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table :error_messages
  end
end
