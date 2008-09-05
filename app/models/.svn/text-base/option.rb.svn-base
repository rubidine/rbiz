# An Option is a variable related to a Product.
# A Customer can pick one Option per OptionSet
# (ie: Option="red" OptionSet="color").
# Options can incur extra weight or cost to be added to the cost of the product.
class Option < ActiveRecord::Base
  belongs_to :option_set
  has_and_belongs_to_many :product_option_selections
  has_many :option_specifications

  validates_presence_of :option_set
  validates_presence_of :name
  validates_uniqueness_of_tuple :option_set_id, :name

  fixed_point_field :price_adjustment
end
