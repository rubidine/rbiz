module CartLib::ShippingMethods

  # returns [ShippingResponse, ..] that includes each method
  def compute_shipping cart
    if @shipping_processors.nil? or @shipping_processors.empty?
      rv = [ShippingResponse.new(
        :success => false,
        :message => 'There is no shipping module installed',
        :body => ""
      )]
    else
      rv = @shipping_processors.collect do |name, mod|
        x = mod.process(cart)
      end.flatten
    end
    rv = rv.sort do |x,y|
           (x.success? and !y.success?) ? -1 : (
             (y.success? and !x.success?) ? 1 : (
               (x.cost_fixed <=> y.cost_fixed)
             )
           )
         end
    unless rv.first.success?
      log_error "Shipping", "#{cart.customer.email}: " +
                "No shipment method availalbe -- " +
                rv.collect{|x| "#{x.plugin_name} #{x.subtype} -> #{x.message}"}.join(' -- ')
    end

    bad = rv.select{|x| !x.success?}
    good = rv.select{|x| x.success?}

    if ENV['RAILS_ENV'] == 'development'
      rv.select{|x| !x.success?}.each do |x|
        RAILS_DEFAULT_LOGGER.error "\nXX BAD SHIPPING\n#{x.inspect}"
      end
    end

    if good.empty? and !bad.empty?
      bad.each do |x|
        log_error 'Shipping', "#{cart.customer.email}: #{x.message}"
      end
    end

    good.empty? ? bad : good
  end

  # uniq_key is a symbol or string that identifies this module
  # module.respond_to? process(type, cart)
  def register_shipping_processor mod
    @shipping_processors ||= {}
    uniq_code = mod.name
    return unless verify_uniq_shipping_processor uniq_code
    return unless verify_shipping_module mod
    install_shipping_processor uniq_code, mod
  end

  private
  def verify_uniq_shipping_processor uniq_code
    !@shipping_processors[uniq_code]
  end

  def verify_shipping_module mod
    return false unless mod.respond_to?(:process)
    true
  end

  def install_shipping_processor uniq_code, mod
    @shipping_processors[uniq_code] = mod
  end

end
