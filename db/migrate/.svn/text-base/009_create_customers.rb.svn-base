class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :email, :string
      t.column :passphrase, :string
      t.column :created_at, :timestamp
      t.column :last_login, :timestamp
      t.column :super_user, :boolean
      t.column :reset_password, :boolean
    end
  end

  def self.down
    drop_table :customers
  end
end
