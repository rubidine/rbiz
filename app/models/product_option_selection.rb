# A ProductOptionSelection encodes availability data for a Product and a set
# of Options.  For any Product, each OptionSet should have one Option present
# in a ProductOptionSelection.  Given a ProductOptionSelection you can know
# what product someone is buying, and what options they selected to be on it.
class ProductOptionSelection < ActiveRecord::Base
  belongs_to :product
  has_and_belongs_to_many :options
  has_many :line_items
  has_many :quantity_reservations, :as => :reserved_object, :dependent => :destroy

  fixed_point_field :price_adjustment

  validates_presence_of :product
  validate :one_option_per_option_set

  before_create :default_to_unlimited_quantity

  # Return a list of options that allow specifications (ordered by set name)
  # (caches result to avoid select / sort calls)
  def options_with_specifications
    @options_with_specs ||= options.select{|x| x.has_input?}.sort_by{|x| x.option_set.name}
  end

  # Return the total of the price adjustment for all the options (fixed width) 
  def price_adjustment_fixed 
    options.inject(0){|m,x| m + x.price_adjustment_fixed.to_i} 
  end 
 
  # Return the total of the price adjustment for all the options (fixed width) 
  def price_adjustment 
    price_adjustment_fixed / 100.0 
  end 
 
  # Return the total of the weight adjustment for all the options 
  def weight_adjustment 
    options.inject(0.0){|m,x| m + (x.weight_adjustment || 0.0)} 
  end 

  def self.ids_for_option_ids option_ids
    if option_ids.length > 0
      joins = ""
      where = ""
      option_ids.each_with_index do |x,index|
        if index != 0
          joins << " JOIN options_product_option_selections opos#{index} " +
                   "ON opos0.product_option_selection_id = " +
                   "opos#{index}.product_option_selection_id"
        end
        where << (!where.empty? ? ' AND ' : '')
        where << " opos#{index}.option_id = #{x.to_i} "
      end
      rv = find_by_sql [
        "SELECT DISTINCT opos0.product_option_selection_id
        FROM options_product_option_selections opos0
        #{joins}
        WHERE #{where}"
      ]
    else
      rv = find_by_sql "SELECT DISTINCT product_option_selection_id " +
                       "FROM options_product_option_selections" 
    end
    rv.collect{|x| x.product_option_selection_id}
  end

  private

  def default_to_unlimited_quantity
    unless self.quantity
      self.unlimited_quantity = true
    end
  end

  def one_option_per_option_set
    sets = options.collect{|x| x.option_set}
    if sets.length != sets.uniq.length
      errors.add(:options, "have a repeated option set: #{sets.inspect}")
    elsif sets.length != product.option_sets.count
      errors.add(:options, "doesn't provide for every option set")
    end
  end

  #
  # The 'quantity_committed' column should only be changed by the counter cache
  #
  def dont_write_cache_commitment
    if changes['quantity_committed']
      self.quantity_committed = changes['quantity_committed'][0]
    end
  end

  def load_cached_commitment
    self.quantity_committed = quantity_reservations.count
  end
end
