# This is the base class (using STI) for FulfillmentResponse, BililngResponse,
# and ShippingResponse
class GatewayResponse < ActiveRecord::Base
  belongs_to :cart

  fixed_point_field :cost

  before_save :stringify_subtype

  private
  def stringify_subtype
    self.subtype = subtype.to_s if subtype
  end
end
