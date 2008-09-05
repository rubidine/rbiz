# Coupons discount the price of the purchase, they may do this in one of
# the following ways:
#  * Discount a particular item
#  * Discount a set of items
#  * Discount the entire order
#  * Discount shipping
#
# Of course, not every coupon should apply to every purchase, so there are
# ways of specifying requirements:
#  * Require one of a certain set of products be purchased
#  * Require N distinct products a certain set of products be purchased
#  * Require N total products (a product being bought twice counts as 2)
#  * Require N total products of a certain set of products
#  * Total price of purchase >= some number
#  * Always applies
#
# There are ways discounts can be applied to products:
#  * Discount all instances of products that are required
#  * Discount all instances of a certain set (other than required)
#  * Discount all an item that is equal or lesser value from a required product
#  * Discount the highest priced item that was required
#  * Discount the highest priced item that is in a set other than required
#  * Create a custom duplicate line from some product's line and discount it
#  
# Each line item that a coupon discounts can apply to:
#  * Discount the entire line
#  * Discount a single item
#
# Discounts can be based on percentages off, or a distinct price.
#
# Examples:
#
# For a buy-three-get-one-free of ItemX:
#   c = Coupon.new :code => 'My CHeckout-C0de'
#   c.required_products << Product.find_by_sku('ItemX')
#   c.requires_total_count = 4
#   c.applies_max_required = true
#   c.discount_percent = 100
#   c.save
# Or really
#   c = Coupon.new :code => 'My CHeckout-C0de'
#   c.required_products << Product.find_by_sku('ItemX')
#   c.double_line = true
#   c.buy_this_many = 3
#   c.get_this_many = 1
#   c.discount_percent = 100
#   c.save
#
# For a buy-a-robe-get-slippers-10-percent-off:
#   c = Copuon.new :code => 'free slippers!'
#   c.required_products << Product.find_by_sku('robe')
#   c.associated_products << Product.find_by_sku('slippers')
#   c.applies_max_associated = true
#   c.discount_percent = 10
#   c.save
#
class Coupon < ActiveRecord::Base
  has_and_belongs_to_many(
    :required_products,
    :class_name => 'Product',
    :join_table => 'coupons_required_products',
    :association_foreign_key => 'product_id'
  )
  has_and_belongs_to_many(
    :associated_products,
    :class_name => 'Product',
    :join_table => 'coupons_associated_products',
    :association_foreign_key => 'product_id'
  )

  has_and_belongs_to_many :carts

  before_validation :clear_ineffective_on_if_no_end

  validates_uniqueness_of :code
  validates_presence_of :code
  validates_presence_of :effective_on

  fixed_point_field :requires_minimum_purchase
  fixed_point_field :discount_price

  validate :has_required_products_if_needs_some
  validate :has_associated_products_if_needs_some
  validate :has_no_more_than_one_requirement
  validate :has_one_application_method
  validate :has_one_discount_method
  validate :cannot_require_more_distinct_products_than_are_associated
  validate :double_line_requires_buy_this_many
  validate :double_line_requires_get_this_many

  # Make sure the coupon has not expired, or has not been actived yet
  def available? date=Date.today
    effective_on <= date and ineffective_on.nil? or ineffective_on > date
  end

  # Check to see if this copuon can apply to the given cart.
  # We check the line items against the required products.  There
  # can be no line items, but requires_total_count and requires_minimum_purchase
  # will still check that that amount of any product is in the cart.
  def applies_to? cart
    return false unless available?

    rl = lines_for_products(cart, required_products)
    al = lines_for_products(cart, associated_products)
    ol = cart.line_items - al - rl

    return false unless meets_requires_minimum_purchase?(rl, al, ol)
    return false unless meets_requires_all?(rl, al, ol)
    return false unless meets_requires_any?(rl, al, ol)
    return false unless meets_requires_distinct_count?(rl, al, ol)
    return false unless meets_requires_total_count?(rl, al, ol)

    return false unless meets_can_apply_to_max_associated?(rl, al, ol)
    return false unless meets_can_apply_to_all_associated?(rl, al, ol)

    return false unless meets_can_apply_to_max_lte_required?(rl, al, ol)
    return false unless meets_can_apply_to_max_lte_associated?(rl, al, ol)
    return false unless meets_can_apply_to_max_lte_other?(rl, al, ol)

    true
  end

  # find the discount for the purchase based on this coupon
  # XXX what if there is more than one coupon, say two coupons that
  # give free shipping, would shipping become a negative number?
  def discount_for_fixed cart
    return 0 unless applies_to? cart

    rl = lines_for_products(cart, required_products)
    al = lines_for_products(cart, associated_products)
    ol = cart.line_items - al - rl

    value = 0
    value += apply_to_total cart, rl, al, ol
    value += apply_to_shipping cart, rl, al, ol
    value += apply_all_required cart, rl, al, ol
    value += apply_all_associated cart, rl, al, ol
    value += apply_max_required cart, rl, al, ol
    value += apply_max_associated cart, rl, al, ol
    value += apply_max_equal_lesser_required cart, rl, al, ol
    value += apply_max_equal_lesser_associated cart, rl, al, ol
    value += apply_max_equal_lesser_other cart, rl, al, ol

  end

  # Floating point version of discount_for_fixed
  def discount_for cart
    discount_for_fixed(cart) / 100.0
  end

  def create_double_lines_for cart
    return [] unless double_line?
    ll = cart.line_items.select{|x| required_product_ids.include?(x.product_id)}
    ll.collect do |req_line|
      multiplier = (req_line.quantity.to_f / buy_this_many).floor
      multiplier = 1 if double_line_only_once?
      quantity = get_this_many * multiplier

      price = req_line.individual_price_fixed - \
              discount(req_line.individual_price_fixed)

      discount_text = discount_percent ? (
                        discount_percent == 100 ? \
                          "Free" : "#{discount_percent}% Off"
                        ) : (
                        discount_price == reg_line.individual_price ? \
                          "Free" : "$#{'%.2f' % discount_price} Off"
                        )

      description = "#{code} - Buy #{buy_this_many}, " +
                    "Get #{get_this_may} #{discount_text} - #{req_line.name}"

      li = req_line.create_coupon_line(
             :custom_price_fixed => price,
             :quantity => quantity,
             :custom_description => description,
             :coupon_id => self.id,
             :cart => req_line.cart
           )
    end
  end

  def update_quantity_of_coupon_line line
    return if double_line_only_once?
    req_line = line.double_line
    multiplier = (req_line.quantity.to_f / buy_this_many).floor
    line.update_attribute(:quantity, get_this_many * multiplier)
  end

  def require_skus
    required_products.collect{|x| x.sku}.join("\n")
  end

  def require_skus= skus
    required_products.clear
    skus = skus.split
    skus.collect!{|x| x.strip}
    skus.reject!{|x| x.empty?}
    skus.each do |x|
      if p = Product.find_by_sku(x)
        required_products << p 
      else
        errors.add :require_skus, "unknown sku `#{x}`"
      end
    end
  end

  def associate_skus
    associated_products.collect{|x| x.sku}.join("\n")
  end

  def associate_skus= skus
    associated_products.clear
    skus = skus.split
    skus.collect!{|x| x.strip}
    skus.reject!{|x| x.empty?}
    skus.each do |x|
      if p = Product.find_by_sku(x)
        associated_products << p
      else
        errors.add :associate_skus, "unknown sku `#{x}`"
      end
    end
  end

  def no_end?
    ineffective_on.nil?
  end
  alias :no_end :no_end?

  def no_end= ne
    @disallow_ineffective_on = ne.to_i.nonzero?
  end

  private
  def lines_for_products cart, products
    cart.line_items.select{|x| x.product and products.include?(x.product)}
  end

  def discount(amount)
    return [discount_price_fixed, amount].min if discount_price?
    (amount * (discount_percent / 100.0)).round
  end

  def meets_requires_minimum_purchase? rl, al, ol
    return true unless requires_minimum_purchase?
    rl = (al + ol) if rl.empty?
    tp = rl.inject(0){|m,x| m + x.price_fixed}
    return tp >= requires_minimum_purchase_fixed
  end

  def meets_requires_all? rl, al, ol
    return true unless requires_all? and !required_products.empty?

    # collect the product id since options / option specifications can make
    # more than one line for a single product
    return rl.collect{|x| x.product_id}.uniq.length == required_products.length
  end

  def meets_requires_any? rl, al, ol
    return true unless requires_any?
    return !rl.empty?
  end

  def meets_requires_distinct_count? rl, al, ol
    return true unless requires_distinct_count?
    rl = (al + ol) if rl.empty?
    return rl.length >= requires_distinct_count
  end

  def meets_requires_total_count? rl, al, ol
    return true unless requires_total_count?
    rl = (al + ol) if rl.empty?
    tc = rl.inject(0){|m,x| m + x.quantity}
    return tc >= requires_total_count
  end

  def meets_can_apply_to_max_associated? rl, al, ol
    return true unless applies_max_associated?
    return !al.empty?
  end

  def meets_can_apply_to_all_associated? rl, al, ol
    return true unless applies_all_associated?
    return !al.empty?
  end

  def meets_can_apply_to_max_lte_required? rl, al, ol
    return true unless applies_max_equal_lesser_required?
    return rl.collect{|x| x.product_id}.uniq.length >= 2
  end

  def meets_can_apply_to_max_lte_associated? rl, al, ol
    return true unless applies_max_equal_lesser_associated?
    return false if al.empty?
    max = rl.collect{|x| x.individual_price_fixed}.max
    return al.detect{|x| x.individual_price_fixed <= max}
  end

  def meets_can_apply_to_max_lte_other? rl, al, ol
    return true unless applies_max_equal_lesser_other?
    return false if ol.empty?
    max = rl.collect{|x| x.individual_price_fixed}.max
    return ol.detect{|x| x.individual_price_fixed <= max}
  end

  def apply_to_total cart, rl, al, ol
    return 0 unless applies_total?
    return discount(cart.total_price_fixed)
  end

  def apply_to_shipping cart, rl, al, ol
    return 0 unless applies_shipping?
    return discount(cart.shipping_price_fixed || 0)
  end

  def apply_all_required cart, rl, al, ol
    return 0 unless applies_all_required?
    rl.inject(0){|m,l| m + (discount(l.individual_price_fixed) * l.quantity)}
  end

  def apply_all_associated cart, rl, al, ol
    return 0 unless applies_all_associated?
    al.inject(0){|m,l| m + (discount(l.individual_price_fixed) * l.quantity)}
  end

  def apply_max_required cart, rl, al, ol
    return 0 unless applies_max_required?
    li = rl.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    li = li.first
    discount(li.individual_price_fixed) * (discount_entire_line? ? li.quantity : 1)
  end

  def apply_max_associated cart, rl, al, ol
    return 0 unless applies_max_associated?
    li = al.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    li = li.first
    discount(li.individual_price_fixed) * (discount_entire_line? ? li.quantity : 1)
  end

  def apply_max_equal_lesser_required cart, rl, al, ol
    return 0 unless applies_max_equal_lesser_required?
    li = rl.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    li = li[1]
    discount(li.individual_price_fixed) * (discount_entire_line? ? li.quantity : 1)
  end

  def apply_max_equal_lesser_associated cart, rl, al, ol
    return 0 unless applies_max_equal_lesser_associated?
    maxl= rl.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    maxl = maxl.first
    li = al.reject{|x| x.individual_price_fixed > maxl.individual_price_fixed}
    ml = li.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    ml = ml.first
    discount(ml.individual_price_fixed) * (discount_entire_line? ? ml.quantity : 1)
  end

  def apply_max_equal_lesser_other cart, rl, al, ol
    return 0 unless applies_max_equal_lesser_other?
    maxl= rl.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    maxl = maxl.first
    li = ol.reject{|x| x.individual_price_fixed > maxl.individual_price_fixed}
    ml = li.sort{|x,y| y.individual_price_fixed <=> x.individual_price_fixed}
    ml = ml.first
    discount(ml.individual_price_fixed) * (discount_entire_line? ? ml.quantity : 1)
  end

  def has_required_products_if_needs_some
    needs_required = [
      applies_all_required?,
      applies_max_required?,
      applies_max_equal_lesser_required?,
      applies_max_equal_lesser_associated?,
      applies_max_equal_lesser_other?
    ]
    if needs_required.any?{|x| x } and required_products.empty?
      errors.add(
        :required_products,
        'is empty but the application method requires it to be set'
      )
    end
  end

  def has_associated_products_if_needs_some
    needs_associated = [
      applies_all_associated?,
      applies_max_associated?,
      applies_max_equal_lesser_associated?,
    ]
    if needs_associated.any?{|x| x } and associated_products.empty?
      errors.add(
        :associated_products,
        'is empty but the application method requires it to be set'
      )
    end
  end

  def has_no_more_than_one_requirement
    unless required_products.empty?
      reqs = [
        requires_all?,
        requires_any?,
        (requires_distinct_count || 0) > 0,
        (requires_total_count || 0) > 0,
        (requires_minimum_purchase || 0) > 0
      ]
      reqs.reject!{|x| !x } # remove nil/false (compact! is just for nil)

      if reqs.length != 1
        errors.add(
          :requires_any,
          'select exactly one requirement type for required products ' +
          '(requires_any, requires_all, requires_discinct_count, ' +
          'requires_total_count, requires_minimum_purchase).'
        )
      end
    end

  end

  def has_one_application_method
    apply = [
      applies_all_required?,
      applies_all_associated?,
      applies_total?,
      applies_max_required?,
      applies_max_associated?,
      applies_max_equal_lesser_required?,
      applies_max_equal_lesser_associated?,
      applies_max_equal_lesser_other?,
      applies_shipping?,
      double_line?
    ]
    apply.reject!{|x| !x } # remove nil or false

    if apply.length != 1
      errors.add(:applies_to, "-- pick exactly one application")
    end
  end

  def has_one_discount_method
    disc = [
      discount_percent|| 0,
      discount_price|| 0,
    ]
    disc.reject!{|x| x <= 0 }
    if disc.length != 1
      errors.add(:discount_percent, "or discount price must be set (only 1)")
    end
  end

  def cannot_require_more_distinct_products_than_are_associated
    if (requires_distinct_count || 0) > 0
      if required_products.length < requires_distinct_count
        errors.add(
          :requires_distinct_count,
          'cannot be greater than the number of required products.'
        )
      end
    end
  end

  def double_line_requires_buy_this_many
    if double_line? and buy_this_many.nil?
      errors.add(:buy_this_many, 'should be specified')
    end
  end

  def double_line_requires_get_this_many
    if double_line? and get_this_many.nil?
      errors.add(:get_this_many, 'should be specified')
    end
  end

  def clear_ineffective_on_if_no_end
    if @disallow_ineffective_on
      self.ineffective_on = nil
    end
  end
end
