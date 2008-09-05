# An OptionSpecification is a customer input to a specific option.  It belongs
# to a LineItem, because the same product, with the same options, is still a
# different line item if the supplied text is not the same.
#
# An example use would be selling bath towels with optional monogramming,
# OptionSet = 'Monogram Towels?' => Option = 'Yes (+ $5)' => SEPCIFICATION_INPUT
class OptionSpecification < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :option

  validates_presence_of :option_text
end
