##
# A QuantityReservation is built for each copy of a Product
# (or Variation) a Customer puts in their Cart.
#
# This gives an order (by timestamping) that reservations were made in,
# so if supplies get low, you have reserved yours already.
#
# These will expire if they sit around too long, though.
#
class QuantityReservation < ActiveRecord::Base
  #
  # First-class Associations
  #
  belongs_to :reserved_object,
             :polymorphic => true,
             :counter_cache => 'quantity_committed'
  belongs_to :line_item, :counter_cache => true
  
  #
  # Denormalized association
  #
  belongs_to :cart

  #
  # Validations
  #
  validates_presence_of :reserved_object_id, :reserved_object_type

end
