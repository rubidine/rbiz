#
# Big monolithic controller for all cart actions.
# 
# TODO
#      i18n
#      namespace with multiple controllers, or resources
#      better handling of trying to look at a missing product
#
class CartController < ApplicationController

  # dont log the cc number!
  filter_parameter_logging "number", "verification_value"

  helper :cart_common

  before_filter :set_customer
  before_filter :cart_login,
                :except => [
                  'index', 'show', 'add_to_cart', 'tag',
                  'update_quantities', 'product', 'error'
                ]
  before_filter :set_cart, :except => ['receipt', 'receipt_post']
  before_filter :cart_for_receipt, :only => ['receipt', 'receipt_post']
  before_filter :addresses_set, :only => ['finalize', 'finalize_post']
  before_filter :cart_not_empty,
                :except => [
                  'show', 'receipt', 'tag', 'product', 'index', 'add_to_cart',
                  'error', 'receipt_post'
                ]

  #
  # List all featured products.
  #
  def index
    @products = Product.featured.available.paginate(
                  :per_page =>
                    (CartConfig.get(:products_per_page, :store) || 15),
                  :page => (params[:page] || 1).to_i,
                  :readonly => true,
                  :order =>'updated_at desc'
                )
  end

  #
  # Show all products with a certain tag.
  #
  def tag
    @tags = Tag.tags_for_slugs(params[:slugs])
    @related_tags = Tag.related_for @tags
    @products = Product.normal_ordering.paginate_for_tags(@tags, params[:page])
  end

  #
  # View details for a product.
  #
  def product
    @product = Product.find_by_slug(params[:id])

    # XXX what if it is unavailable

    # TODO, better handling of this condition
    unless @product
      render :text => "Product Not Found: #{params.inspect}", :status => 404
    end
  end

  #
  # Add a product to a cart.
  # Can be a post if there are options / specifications.
  # Can also be a get if just a product.
  # Checks options and option specifications.
  # Redirects to /cart/show
  #
  # TODO
  #   Take out the Error-redirect-return cycle and replace it with exceptions
  def add_to_cart
    product = Product.find(params[:id])
    product_option_selection = nil

    # XXX make this skinny!

    unless product
      flash[:warning] = "You did not request a valid product or the product " +
                        "has been removed from the store."
      session[:params] = params.dup
      redirect_to :action => 'error'
      return
    end

    # XXX
    # This is handled in the Cart#add method, do we really need it here?
    unless product.available?
      if product.effective_on.nil? or product.effective_on > Date.today
        flash[:warning] = "#{product.name.capitalize} is not available yet."
      else
        flash[:warning] = "#{product.name.capitalize} has gone off the market."
      end
      session[:params] = params.dup
      redirect_to :action => 'error'
      return
    end

    # make sure we have option specification (variant) if we need it
    # (and cache up the individual options)
    if params[:options]
      product_option_selection = product.product_option_selections.find_by_id(
                                   params[:options].to_i,
                                   :include => [:options]
                                 )
    end

    # XXX TEST IF THIS CAN GO AWAY AND BE HANDLED BY Cart#add
    # TODO: could we mark a product_option_selection as default
    # and try to use it if there are missing options?
    if product.has_options? and !product_option_selection
      flash[:warning] = "Cannot add product to cart without specifying options."
      session[:params] = params.dup
      redirect_to :action => 'error'
      return
    end

    # Specifications for options that request it.
    # We don't do params[:specifications].each since they could potentially
    # be bogus or lacking in something we need to be set.  We match up the
    # iteration technique we use to retrieve them.
    specs = {}
    if product_option_selection
      reqd_options = product_option_selection.options.select{|x| x.has_input?}
      reqd_options.each do |x|
        str = params[:option_input] ? params[:option_input][x.id.to_s].to_s : ''
        specs[x] = str
      end
    end

    # make the line item
    qty = (params[:quantity] || '1').gsub(/[^\d]+/, '').to_i
    qty = 1 unless qty >= 1
    line_item = @cart.add((product_option_selection || product), qty, specs)
    unless line_item
      flash[:warning] = "Unable to create line item for product.  " +
                        "#{@cart.error_message}"
      redirect_to :action => 'error'
      return
    end

    # if this line is tracked by a coupon for special discounts, apply them
    if cl = line_item.coupon_line
      cl.coupon.update_quantity_of_coupon_line(cl)
    end 

    # save the cart, so we know when the last action was taken on it
    @cart.save

    # redirect to show cart action
    # don't render action=>show, refresh would re-add product on this action
    redirect_to :action => 'show'
  end

  #
  # post back from 'show' action that changes quantities of an item in the cart
  # the checkout link also takes us here, to update quantities first
  # we are redirected based on where we're going
  #
  def update_quantities
    if params[:quantities]
      params[:quantities].each do |id, num|
        li = @cart.update_quantity(id, num)

        if !li
          p = @cart.line_items.find(id) rescue nil
          if p
            (flash[:notice] ||= '') << "Unable to change quantity of " +
                                       "#{p.name} to #{num}, there are not "+
                                       "enough available at this time."
          end
        else #updated quantity
          # update any coupon generated lines for this line
          if cl = li.coupon_line
            cl.coupon.update_quantity_of_coupon_line(cl)
          end 
        end
      end

      # if any master lines for coupon lines were destroyed,
      # remove their coupon lines as well
      @cart.line_items.select{|x| x.custom_double_line_id}.each do |cl|
        unless @cart.line_items.find_by_id(cl.custom_double_line_id)
          cl.destroy
        end
      end

      # (and their coupons)
      @cart.coupons.each do |x|
        @cart.coupons.delete(x) unless x.applies_to?(@cart)
      end

    end

    # update comments as well
    if params[:cart] and params[:cart][:comments]
      @cart.comments = params[:cart][:comments]
    end

    # build the redirect Url Options based on submitted action and
    # what already exists in the session
    uo = {}
    if params[:commit] == 'Checkout'
      uo = build_url_options_for_checkout
    else # just update
      uo = {:controller => 'cart', :action => 'show'}
    end

    # save the cart, so we know when the last action was taken on it
    unless @cart.save
      flash[:warning] = "Unable to save cart: <ul><li>" +
                        "#{@cart.errors.full_messages.join('</li><li>')}" + 
                        "</li></ul>"
    end

    redirect_to uo
  end

  #
  # Add a new address into the system.  This will actually set the shipping
  # address AND the billing address (unless it is already set) and go straight
  # to the finalize screen.  The finalize screen will link back to the billing
  # address in case they are not the same.
  #
  def shipping_address_post
    @address = Address.new(params[:address])
    @address.customer = @customer
    if @address.save
      @cart.shipping_address = @address
      unless @cart.billing_address
        @cart.billing_address = @address
      end
      if @cart.save
        redirect_to build_url_options_for_checkout
        return
      end
    else
      flash[:error] = @address.errors.full_messages.join('<br/>')
      render :action => 'shipping_address'
    end
  end

  #
  # If the user already has addresses entered, they can pick one and go here
  # this will save the cart and move to the next point in the checkout.
  # Will default the billing address to here as well.
  #
  def ship_to_existing
    address = Address.find params[:id]
    unless address.customer_id.eql?(@customer.id)
      redirect_to :controller=>'cart', :action=>'shipping_address'
      return
    end

    @cart.shipping_address = address
    unless @cart.billing_address
      @cart.billing_address = address
    end
    @cart.save
    redirect_to build_url_options_for_checkout
  end

  #
  # Add a new address into the system and use it for billing information
  # on this credit card.
  #
  def billing_address_post
    @address = Address.new(params[:address])
    @address.customer = @customer
    if @address.save
      @cart.billing_address = @address
      @cart.save
      redirect_to build_url_options_for_checkout
      return
    else
      flash[:error] = @address.errors.full_messages.join('<br/>')
      render :action => 'billing_address'
    end
  end

  #
  # associate an already existing address with the billing address
  # this is most common, since shipping is almost always the same
  #
  def bill_to_existing
    address = Address.find params[:id]
    unless address.customer_id.eql?(@customer.id)
      redirect_to :controller=>'cart', :action=>'billing_address'
      return
    end
    @cart.billing_address = address
    @cart.save
    redirect_to build_url_options_for_checkout
  end

  #
  # Add a coupon to the cart
  #
  def add_coupon
    # Make sure coupons are enabled
    if CartConfig.get(:coupons, :disable)
      flash[:error] = "Coupons are disabled"
      redirect_back_with_default :action => 'show'
      return
    end

    # Make sure this is the first coupon, or multiples are allowed
    if CartConfig.get(:coupons, :allow_only_one) and !@cart.coupons.empty?
      flash[:warning] = 'Only one coupon can be used at a time'
      redirect_back_with_default :action => 'show'
      return
    end

    ccode = (params[:coupon] || {})[:code]

    # Make sure the customer passes in a coupon code
    if ccode.nil? or ccode.empty?
      flash[:warning] = 'Unable to apply coupon: no code given?'
      redirect_back_with_default :action => 'show'
      return
    end

    coupon = Coupon.find(
               :first,
               :conditions => [
                 'effective_on <= ? AND
                 (ineffective_on >= ? OR ineffective_on IS NULL) AND
                 code = ?',
                 Date.today, Date.today, ccode
               ]
             )

    unless coupon
      flash[:warning] = "Unable to find coupon with code: #{ccode}"
      redirect_back_with_default :action => 'show'
      return
    end

    unless coupon.applies_to?(@cart)
      flash[:warning] = "Your cart does not qualify for coupon"
      redirect_back_with_default :action => 'show'
      return
    end

    if @cart.coupons.include?(coupon)
      flash[:warning] = "Coupon has already been applied to cart"
      redirect_back_with_default :action => 'show'
      return
    end

    @cart.coupons << coupon
    coupon.create_double_lines_for(@cart).each do |cl|
      if cl.new_record?
        (flash[:errors] ||= '') << "Unable to create coupon line: <ul><li>"+
                                cl.errors.full_messages.join('</li><li>') +
                                "</ul>"
      end
    end
    redirect_back_with_default :action => 'show'
  end

  #
  # Genereate a list of payment and shipping methods, and have the
  # Customer fill out a form with payment info.  This is where they
  # accept payment.
  #
  def finalize
    # initialize to clean state
    @cart.freight_shipping = false
    @cart.shipping_error = false
    @cart.error_message = ''
    @cart.shipping_responses.clear
    @cart.payment_responses.clear
    @cart.fulfillment_responses.clear

    @shipping_methods = CartLib.compute_shipping(@cart)
    if @shipping_methods.empty?
      @cart.shipping_error = true
      @cart.error_message = "No shipping methods available"
    elsif !@shipping_methods.first.success?
      @cart.shipping_error = true
      @cart.error_message = "None of the available shipping methods is appropriate."
    else
      @cart.shipping_computed_at = Time.now
      @shipping_methods.select{|x| x.success?}.each{|x| @cart.shipping_responses << x ; x.save}
    end
    @cart.save
  end

  #
  # Submit their payment information through the configured gateway.
  # If successful, send order for fulfillment.
  #
  def finalize_post
    @cart.comments = params[:cart][:comments]

    # If it has been too long since shipping was computed
    threshold = (CartConfig.get(:shipping_expiration, :payment) || 3).hours
    ca = @cart.shipping_computed_at
    if ca.nil? or ((ca.localtime + threshold) < Time.now.localtime)
      flash[:warning] = 'Idle time exceeded.  ' +
                        'Please check shipping price and confirm payment.'
      render :action => 'finalize'
      return
    end

    if @cart.shipping_responses.length == 1
      resp = @cart.shipping_responses.first
    else
      resp = @cart.shipping_responses.find_by_id(params[:shipping_method][:id])
    end

    if resp.nil?
      flash[:error] = 'Unable to compute shipping!'
      render :action => 'finalize'
      return
    end

    resp.update_attribute :selected, true
    @cart.shipping_price = resp.cost

    @cart.tax_price # compute so it will be saved, in case shipping is taxed

    # Payment method might not be shown, in case of only one payment method
    # with a radiant integrtion or overridden view.  But if it is shown but
    # not selected by customer, prompt them to select.
    if params[:payment] and params[:payment][:method] == '-- SELECT PAYMENT TYPE --'
      flash[:error] = "Select Payment Type"
      render :action => 'finalize'
      return
    end

    status = CartLib.process_payment(@cart, params)

    unless status.is_a?(PaymentResponse) and status.success?
      # wasn't successful, possibly array of multiple failures
      msg = nil
      if status.is_a?(Array)
        status.each do |stat|
          stat.cart = @cart
          stat.save
        end

        if status.empty?
          msg = "Unable to process payment.  No payment module installed?"
        end
      end

      msg ||= status.first.message
      flash[:error] = msg
      ErrorMessage.create(
        :scope => 'Payment',
        :message => "#{@cart.customer.email}: #{msg}"
      )
      render :action => 'finalize'
      return
    end

    status.selected = true
    status.cart = @cart
    status.save
    @cart.error_message = nil
    @cart.mark_as_sold
    @cart.save

    fr = CartLib.process_fulfillment @cart
    @cart.fulfillment_responses = fr

    sel = fr.select{|x| x.success }.first

    # XXX TODO Error check (processed okay, but store admin needs to know)
    # log unsuccessful fulfillment response
    unless sel
      msg = "Unable to fulfill shipping. #{fr.first.message}"

      ErrorMessage.create(
        :scope => 'Fulfillment',
        :message => "#{@cart.customer.email}: #{msg}"
      )
    end

    sel.selected = true
    sel.save

    session[:cart_id] = nil

    redirect_to :controller=>'cart', :action=>'receipt', :id=>@cart.id
  end

  #
  # show their recipt so they can print it
  #
  def receipt
    @cart = Cart.find(params[:id], :readonly => true)

    # only superuser or owner can see the receipt
    unless (@customer and @cart.customer == @customer) \
    or (respond_to?(:current_user) and current_user and current_user.admin?)
      flash[:warning] = "You cannot view your receipts without logging in."
      redirect_to :controller => 'customer', :action => 'login'
      return
    end
  end

  #
  # They want to recieve their receipt in an email
  #
  def receipt_post
    @cart = Cart.find(params[:id], :readonly => true)

    unless (@customer and @cart.customer == @customer) \
    or (respond_to?(:current_user) and current_user and current_user.admin?)
      flash[:warning] = "You cannot view your receipts without logging in."
      redirect_to :controller=>'customer', :action=>'login'
      return
    end

    OrderNotifier.deliver_receipt @cart
    flash[:notice] = "Email has been sent do #{@cart.customer.email}"
    render :action => 'receipt'
  end

  #
  # A general error message page.  Should have flash, maybe use
  # HTTP_REFERRER to show dumps or emails to admin.
  #
  def error
    @referer = request.env['HTTP_REFERER']
    if session[:params]
      @session_params = session[:params]
      session[:params] = nil
    end
  end

  private

  def set_customer
    @customer = session[:customer_id] ? \
                  Customer.find(session[:customer_id]) : \
                  nil
  end

  # make sure they have a cart saved in their session
  def set_cart
    @cart = nil
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id], :include => [:line_items])
    end
    if @customer and !@cart
      @cart = @customer.carts.find_by_sold_at(nil)
    end
    if !@cart
      @cart = Cart.create(:customer => @customer)
    end
    session[:cart_id] = @cart.id
  end

  # get addresses before billing / finalize
  def addresses_set
    if @cart.shipping_address.nil?
      redirect_to :action=>'shipping_address'
      return false
    elsif @cart.billing_address.nil?
      redirect_to :action=>'billing_address'
      return false
    end
  end

  # make sure they have logged in, so we can track them
  def cart_login
    unless @customer
      session[:redirect_to] = {
        :controller=>params[:controller],
        :action=>params[:action],
        :id=>params[:id]
      }
      redirect_to :controller=>'customer', :action=>'login'
      return false
    end
  end

  # make sure they have products to buy, or checkout is meaningless
  def cart_not_empty
    if @cart.line_items.length <= 0
      redirect_to :controller=>'cart', :action=>'show'
      return false
    end
  end

  # make sure cart is not a new record before proceeding
  # beyond shipping address
  def saved_cart
    if @cart.new_record? and !@cart.save
      redirect_to :action=>'shipping_address'
    end
  end

  # order: shipping, billing, payment, finalize
  def build_url_options_for_checkout
    if @cart.shipping_address.nil?
      uo = {:controller=>'cart', :action=>'shipping_address'}
    elsif @cart.billing_address.nil?
      uo = {:controller=>'cart', :action=>'billing_address'}
    else
      uo = {:controller=>'cart', :action=>'finalize'}
    end

    # for any of the checkout actions, go to ssl if needed
    if CartConfig.get(:ssl, :payment)
      uo[:protocol] = 'https://'
      uo[:only_path] = false
    end
    uo
  end

  def redirect_back_with_default defaults={}
    begin
      redirect_to :back
    rescue
      redirect_to defaults
    end
  end

  def cart_for_receipt
    @cart = Cart.find(params[:id])
  end

end
