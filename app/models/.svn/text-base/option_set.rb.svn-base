# An OptionSet contains Options in logical groups, so that only one Option
# per OptionSet can be selected.
class OptionSet < ActiveRecord::Base
  has_many :options
  belongs_to :product

  validates_presence_of :name
  validates_presence_of :product
  validates_uniqueness_of_tuple :name, :product_id

end
