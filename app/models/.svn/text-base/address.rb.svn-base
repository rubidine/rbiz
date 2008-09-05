# Address stores a name, street address, city, state, zipcode
# Belongs to a customer
# Carts belong to addresses as :billing_address / :shipping_address
class Address < ActiveRecord::Base
  belongs_to :customer
  validates_presence_of :customer_id
  validates_presence_of :street
  validates_presence_of :display_name
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip
end
