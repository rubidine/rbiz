#
# LineItem is an entry on a Cart, equivilent to a line on a receipt.
# They contain the product being purchased, a pointer to any options
# that may apply to that product, and a quantity.  These attributes
# can be used to compute the cost of the line item.
#
# You are also allowed custom line items: entries that have no product
# associated with them, but have a description and price keyed in manually
# (or by a coupon).
# 
# Products
# Line items usually just store a quantity and a pointer to a product.
#
# Options
# Some products have options that must be chosen by the buyer.  We store
# a pointer to the Variation that this line item applies to,
# and itterate over its options to check for price adjustments, and the
# name of the OptionSet and the value of the option are also applied
# to the sku.
#
# Custom Lines
# Discounts and custom prices can be added to the cart.  Just set custom_price
# and custom_description. Quantity still needs to be set as well.
#
class LineItem < ActiveRecord::Base

  validates_presence_of :quantity, :cart_id
  validates_numericality_of :quantity, :integer=>true

  validate_on_create :valid_product_or_custom_line_item
  validate_on_create :no_product_if_custom
  validate_on_create :ensure_product_is_available
  validate_on_create :ensure_quantity_commited_is_quantity_requested

  belongs_to :cart
  belongs_to :product
  belongs_to :variation
  has_many :option_specifications
  has_many :quantity_reservations, :dependent => :destroy

  belongs_to :custom_double_line,
             :class_name => 'LineItem',
             :foreign_key => 'custom_double_line_id'
  has_one :coupon_line,
          :class_name => 'LineItem',
          :foreign_key => 'custom_double_line_id'
  belongs_to :coupon

  before_save :dont_save_quantity_cache
  after_create :reset_quantity_reservations_count

  fixed_point_field :custom_price

  # Check to see if a line is custom or product based.
  def custom?
    !read_attribute(:custom_price).nil?
  end

  # Should change the quantity of this line item, if enough of product are
  # available.
  #
  # Returns true if quantity committed, false if not enough.
  #
  # Quantity will always be set to the true amount.
  def update_quantity num
    raise "Trying to modify a line already sold" if sold_at

    old_quantity = quantity
    write_attribute(:quantity, num)

    rv = nil
    if commit_quantity
      rv = new_record? ? true : save
    else
      write_attribute(:quantity, old_quantity)
      rv = false
    end

    # update quantity_reservation_count to keep local cache in sync with
    # column written as a counter cache
    self.quantity_reservations_count = quantity_reservations.length

    rv
  end

  # Alias quantity= to update_quantity
  # Done as function instead of alias to get future alias_method(_chain)
  def quantity= num
    update_quantity num
  end

  # When the product is set we need to make sure we block changing an already
  # set product id, since you should never change the product a line item is
  # associated with, since the line item tracks the quantity committed on the
  # Product, and there may be a Variation set that would become
  # invalid.  We also have to block the quantity.
  def product_id= prod_id
    return if product
    super
    commit_quantity
  end

  # When the product is set we need to make sure we set aside enough inventory
  # and block the possiblity of changing an already set product id, since
  # you should never change the product a line item is associated with,
  # since the line item tracks the quantity committed on the Product, and
  # there may be a Variation set that would become invalid.
  def product_with_commit_quantity= prod
    return if self.product
    self.product_without_commit_quantity = prod
    commit_quantity
  end
  alias_method_chain :product=, :commit_quantity

  # Return the floating point price of a single instance of this item.
  # Accounts for discounts / adjustments based on options, etc
  def individual_price
    individual_price_fixed.to_f / 100.0
  end

  # Return the fixed point price of a single instance of this item.
  # Accounts for discounts / adjustments based on options, etc
  def individual_price_fixed
    if custom_price?
      custom_price_fixed
    else
      base_price = product.price_fixed

      # options
      if variation 
        base_price += variation.price_adjustment_fixed
      end

      # return
      base_price
    end
    # Add no more code here:
    # we return based on if / else, (or explicit return above)
  end

  # The price of the overall line item.
  # Based on quantity and individual price, with options, &c.
  # Returns a fixed pioint representation.
  def price_fixed
    quantity * individual_price_fixed
  end

  # The price of the overall line item.
  # Based on quantity and individual price, with options, &c.
  # Returns a floating point representation of the number of dollars.
  def price
    price_fixed / 100.0
  end

  # Since options can specify a weight adjustment, make sure
  # we take it into account
  def individual_weight

    default_weight = CartConfig.get(:default_product_weight, :errors) || 5

    return (custom_weight || 0) if custom?

    # without options, its just the product weight
    base = (product.weight || default_weight)

    # add option weights in
    if variation
      base += variation.weight_adjustment
    end

    base
  end

  # Returns the weight of the entire line item, that is
  # individual_weight * quantity
  def weight
    quantity * individual_weight
  end

  # The full sku is either the custom description or the product sku.
  # If this line item is for a product, the options are also included in
  # the sku.
  def full_sku
    rv = custom? ? custom_description : product.sku
    if product and variation
      options = variation.options.sort_by{|x| x.option_set.sku_extension_order}
      oo = options.collect do |o|
        if o.sku_extension
          o.sku_extension
        else
          "-#{o.option_set.name}=#{o.name}"
        end
      end
      rv += oo.join('-')
    end
    rv
  end

  # return a string of all the specificatins as "OPTION = SPEC - OPT2 = SPEC2"
  def specifications
    rv = [] 
    specification_hash.each do |opt, text| 
      rv << "#{opt.name} = #{text}" 
    end 
    rv.join(' - ') 
  end 
 
  # return a hash of { #<Option> => spec_text } 
  def specification_hash 
    rv = {} 
 
    return rv unless product and variation 
 
    options = variation.options_with_specifications 
    options.each do |o| 
      spec = option_specifications.detect{|s| s.option_id == o.id} 
      rv[o] = spec ? spec.option_text : '' 
    end 
 
    rv 
  end

  # Name of the line item or the custom description
  def name
    custom? ? custom_description : product.name 
  end

  # When we sell a cart, we need to run some finalizing actions,
  # such as actually marking our inventory as gone.
  def mark_as_sold
    decrement_quantity_available_for_item
    remove_quantity_reservations
    mark_database_record_as_sold
  end

  # if this is for a product_option_specification that has options
  # that the customer enters, be sure to record them
  def set_sepcifications specs
    specs.each do |opt, txt|
      option_specifications.create(:option => opt, :option_text => txt)
    end
  end

  private

  #
  # Set the quantity committed on a variation or product.
  # Return true or false based on success.
  #
  def commit_quantity

    # during mass/sequential assign, maybe not both product/quantity are set
    # furthermore, product may have unlimited availability
    return true unless sel = quantity_object and quantity

    diff = quantity.to_i - quantity_reservations_count
    return true if diff == 0

    if diff < 0
      saved_res = quantity_reservations.find(
                    :all,
                    :order => 'created_at desc',
                    :limit => diff.abs
                  )
      saved_res.each do |reservation|
        quantity_reservations.delete(reservation)
      end

      sel.quantity_committed -= diff.abs

      return true
    end

    return false unless reserve_quantity_for_item(diff, sel)

    self.quantity_reservations_count = quantity

    true
  end

  def reserve_quantity_for_item num, itm
    return false if num > itm.quantity

    new_res = []
    num.times do
      new_res << quantity_reservations.build(:reserved_object => itm, :cart_id => cart_id)
    end

    if over_capacity?(new_res, itm)
      new_res.each{|x| x.destroy}
      return false
    else
      # keep a local cache
      itm.quantity_committed += num
      self.quantity_reservations_count += num

      return true
    end
  end

  #
  # If any of these reservations put the order over quanity, return true
  #
  def over_capacity? reservations, sel
    dup = sel.class.find(sel.id)
    over = dup.quantity_committed - dup.quantity
    return false unless over > 0

    to_remove = quantity_reservations.find(
                  :all,
                  :order => 'created_at desc',
                  :limit => over
                )

    # intersection, see if we are in the over-capacity list
    !(to_remove & reservations).empty?
  end

  def valid_product_or_custom_line_item
    if product.nil? and !custom?
      errors.add(:product, 'is not a valid product')
      # which would be okay, but the line item is not custom
    end
  end

  def no_product_if_custom
    if custom? and product
      errors.add(:product, 'is set on a custom line item')
    end
  end

  def ensure_product_is_available
    return true unless product
    return true if product.available?
    errors.add(:product, 'is not available')
  end

  def quantity_object
    return nil if custom?
    if variation && variation.track_quantity_on_product?
      product
    end
    return nil unless sel = variation || product
    sel.unlimited_quantity? ? nil : sel
  end

  def dont_save_quantity_cache
    if changes['quantity_reservations_count']
      self.quantity_reservations_count = changes['quantity_reservations_count'][0]
    end
  end

  def ensure_quantity_commited_is_quantity_requested
    if quantity_object && quantity_reservations_count < quantity
      errors.add :quantity, "Unable to save desired quantity"
    end
  end

  def reset_quantity_reservations_count
    self.quantity_reservations_count = quantity_reservations.count
  end

  def decrement_quantity_available_for_item
    return true unless sel = quantity_object

    connection.execute(
      "UPDATE #{sel.class.table_name}
      SET quantity = quantity - #{quantity}
      WHERE id = #{sel.id}"
    )

    # keep live record in sync with database
    sel.quantity = sel.quantity - quantity
  end

  def remove_quantity_reservations
    quantity_reservations.each{|x| x.destroy}
  end

  def mark_database_record_as_sold
    self.sold_at = Time.now
    save
  end
end
