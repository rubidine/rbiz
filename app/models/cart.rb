# The Cart is what makes it go around.  You have one in your session, and if
# you log in, it finds any you tried to have earlier and didn't check out.
# Products are held in the cart by line items, which have a product, and 
# variation and user-input option specifications (if applicable for that
# product), and the quantity requested of that product.
#
# If an error occurs, check the error_message attribute for a human-readable
# error message that could be logged and /or shown to end users.
class Cart < ActiveRecord::Base
  belongs_to :customer
  belongs_to :shipping_address,
             :class_name=>'Address',
             :foreign_key=>'shipping_address_id'
  belongs_to :billing_address,
             :class_name=>'Address',
             :foreign_key=>'billing_address_id'
  has_many :line_items
  has_many :shipping_responses
  has_many :payment_responses
  has_many :fulfillment_responses

  has_and_belongs_to_many :coupons, :uniq => true

  fixed_point_field :total_price
  fixed_point_field :shipping_price
  fixed_point_field :tax_price

  # Return a textual representation of the status of the cart
  def status_message
    if customer
      if shipping_address
        if sold_at
          if fulfilled_at
            "Sold and fulfilled"
          else
            if fulfillment_error?
              "Error in fulfillment"
            else
              "Sold: Awaiting Fulfillment"
            end
          end
        else
          if billing_error?
            "Error in billing"
          elsif shipping_error?
            "Error in shipping"
          else
            "Checkout in prgress"
          end
        end
      else
        "Not Checked Out"
      end
    else
      "Not Logged In"
    end
  end

  # This is to add a product into the cart.  If a line item for it already
  # exists, then the quantity will simply be updated.
  #
  # Returns false and sets @cart.error_message if item could not be added.
  # Otherwise returns the line item.
  def add product_or_selection, quantity = 1, specifications = {}
    quantity = quantity.to_i

    li = find_or_create_line_for(product_or_selection, specifications)
    if li
      li = set_quantity_of_line(li, quantity + li.quantity)
      shipping_computed_at = nil
    end

    li
  end

  # Finds the line item for a given item and changes the quantity in the cart.
  # You can remove an item from the cart by setting num = 0.
  # Returns the updated line item if updated.
  # Returns nil if line item not found or just removed.
  # Returns flase if unable to update.
  def update_quantity line_item_id, num
    line_item_id = line_item_id.to_i
    num = num.to_i
    li = line_items.detect{|x| x.id == line_item_id}

    return nil unless li

    li = set_quantity_of_line li, num
    return false unless li

    if li.quantity == 0
      line_items.delete(li)
      li.destroy
      return nil
    end

    # Recompute shipping next time around
    shipping_computed_at = nil

    li
  end

  # Return the floating point price for all the items in the cart.
  # This method overwrites the total_price field from fixed_point_field.
  # It is stored in the databse, but can also be computed on the fly.
  # Default is to recompute unless record is readonly.
  def total_price(use_stored_value=readonly?)
    compute_total_price unless use_stored_value
    read_floating_point(:total_price) || 0.0
  end

  # fixed with version of total_price
  # overrides the fixed_point_field version to handle our caching
  def total_price_fixed(use_stored_value=readonly?)
    compute_total_price unless use_stored_value
    read_fixed_point(:total_price) || 0
  end

  # fixed point price
  # the total price of the cart - prices of products that are tax exempt
  def taxable_total(use_stored_value=readonly?)
    total_price_fixed - coupon_rebate_fixed
  end

  # how much tax is on this cart
  # floating point price
  def tax_price(use_stored_value=readonly?)
#    return nil unless self.shipping_address
    compute_tax_price unless use_stored_value
    read_floating_point(:tax_price) || 0.0
  end

  # how much tax is on this cart, as a fixed point number
  def tax_price_fixed(use_stored_value=readonly?)
#    return nil unless self.shipping_address
    compute_tax_price unless use_stored_value
    read_floating_point(:tax_price) || 0.0
    read_fixed_point(:tax_price) || 0
  end

  # the sum of items (total_price)
  # the shipping charge (shipping_price)
  # and tax (tax_price)
  def grand_total_fixed(use_stored_value=readonly?)
    # make sure we have emptied the cache
    total_price_fixed(use_stored_value) + \
    (shipping_price_fixed(use_stored_value) || 0) + \
    tax_price_fixed(use_stored_value) - \
    coupon_rebate_fixed
  end

  # floating point version of grand_total_fixed
  def grand_total(use_stored_value=readonly?)
    (grand_total_fixed(use_stored_value).to_f / 100.0)
  end

  # Coupons alter the price of the cart
  # compute them here
  # (not stored on database)
  def coupon_rebate_fixed
    coupons.inject(0) {|m,x| m + x.discount_for_fixed(self)}
  end

  # Coupons alter the price of the cart
  # compute them here
  # (not stored on database)
  def coupon_rebate
    coupon_rebate_fixed / 100.0
  end

  # When we complete the sell, change the status of the line items, and 
  # set the timestamp on the cart.
  def mark_as_sold
    line_items.each{|x| x.mark_as_sold}
    total_price # write_attribute is called from in here
    self.sold_at = Time.now
  end

  # return true if the cart is taxable
  def taxable?
    state = shipping_address.state[0,2].upcase
    tr = CartConfig.get(:tax_rates, :payment)
    tr and tr[state]
  end

  # return tax rate
  def tax_rate
    state = shipping_address.state[0,2].upcase
    tr = CartConfig.get(:tax_rates, :payment)
    tr[state]
  end

  private

  def find_or_create_line_for product_or_selection, specifications
    li = find_line_item_for(product_or_selection, specifications)
    li ||= create_line_item_for(product_or_selection, 0, specifications)
    li
  end

  # Used throughout to get line item to operate on.
  # Find a line item for the given product or variation.
  def find_line_item_for product_or_selection, specifications

    is_product = product_or_selection.is_a?(Product)

    msg = is_product ? :product_id : :variation_id
    id = product_or_selection.id
    li = line_items.detect{|x| x.send(msg) == id}
 
    return nil unless li
    return li if is_product
    return nil unless specifications_are_same(li, specifications)
    li
  end

  def specifications_are_same li, specifications
    passed = true 
    li.specification_hash.each do |opt, txt| 
      passed = false if specifications[opt] != txt 
    end 
    passed
  end

  def create_line_item_for product_or_selection, quantity, specifications

    if product_or_selection.is_a?(Product)
      product = product_or_selection
      selection = nil
    else
      product = product_or_selection.product
      selection = product_or_selection
    end

    li = line_items.create(
           :quantity => quantity,
           :product => product,
           :variation => selection
         )

    if li.new_record?
      self.error_message = "Unable to add to cart, #{li.errors.full_messages.join(", ")}."
      return false
    end

    li.set_sepcifications(specifications)

    li
  end

  def set_quantity_of_line li, quantity
    unless li.update_quantity(quantity)
      self.error_message = "Unable to set quantity, inventory low."
      return false
    end
    li
  end

  # DRY, since we call for floating and fixed price numbers
  def compute_total_price
    # compute the fixed point pirce of all line items
    tp = line_items.inject(0) do |mark, li|
      mark + li.price_fixed
    end
    set_fixed_point(:total_price, tp)

    tp
  end

  # DRY, since we call for floating and fixed price numbers
  def compute_tax_price
    unless taxable? and shipping_address
      set_fixed_point(:tax_price, 0)
      return 0
    end

    tp = taxable_total
    unless CartConfig.get(:omit_shipping_from_tax, :payment)
      tp += (read_fixed_point(:shipping_price) || 0) 
    end

    tp = (tp * tax_rate).round
    set_fixed_point(:tax_price, tp)

    tp
  end
end
