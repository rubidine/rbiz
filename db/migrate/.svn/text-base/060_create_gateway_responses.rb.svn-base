class CreateGatewayResponses < ActiveRecord::Migration
  def self.up
    create_table :gateway_responses do |t|
      # For Single Table Inheritance (STI)
      t.string :type

      # belongs_to cart
      t.integer :cart_id

      # Plugins should set this data
      t.string :plugin_name, :plugin_version

      # message is what to show user (esp if failure)
      # subtype could be for auth_only / captrue based on card processor,
      #         but is really used for ground / air / &c. for shipping
      # body is the full response from the upstream server (for debugging, etc)
      # success is weather or not it is valid
      # tracking_code is any information that might be needed for additional
      #               tasks to be performed with this data
      #               (such as tracking a package, or 
      #               doing auth_capture for the credit processor)
      # freight is only used for fulfillment really
      # cost is a fixed point field of any cost that is associated with response
      #      (like cost of shipping, or cost of processing a card)
      t.string :message, :subtype
      t.text :body
      t.boolean :success
      t.string :tracking_code
      t.integer :cost

      # selected is set if the user selects the given method out of a set of
      # alternitives (esp for shipping when multiple processors are available)
      t.boolean :selected

      # for completeness
      t.timestamps
    end
  end

  def self.down
    drop_table :gateway_responses
  end
end
