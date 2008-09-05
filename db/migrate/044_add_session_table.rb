class AddSessionTable < ActiveRecord::Migration
  def self.up
    if !defined?(RADIANT_ROOT)
      create_table :sessions do |t|
        t.column :session_id, :string
        t.column :data, :text
        t.column :updated_at, :datetime
      end

      add_index :sessions, :session_id
      add_index :sessions, :updated_at
    end
  end

  def self.down
    if !defined?(RADIANT_ROOT)
      drop_table :sessions
    end
  end
end
