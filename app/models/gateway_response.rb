# This is the base class (using STI) for FulfillmentResponse, BililngResponse,
# and ShippingResponse
class GatewayResponse < ActiveRecord::Base
  belongs_to :cart

  fixed_point_field :cost
end
