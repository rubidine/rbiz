module CartLib::FulfillmentMethods
  # returns FulfillmentResponse instance
  def process_fulfillment cart
    if @fulfillment_processors.nil? or @fulfillment_processors.empty?
      log_error "Fulfillment", "#{cart.customer.email}: " +
                               "No fulfillment processor module installed"
      FulfillmentResponse.new(
        :success => false,
        :message => 'No fulfillment processor module installed',
        :body => ''
      )
    else
      rv = @fulfillment_processors.collect do |name, mod|
        mod.process(cart)
      end
    end
  end

  # uniq_key is a symbol or string that identifies this module
  # module.respond_to? process(type, cart)
  def register_fulfillment_processor mod
    uniq_code = mod.name
    return unless verify_uniq_fulfillment_processor(uniq_code)
    return unless verify_fulfillment_module(mod)
    install_fulfillment_processor(uniq_code, mod)
  end

  private
  def verify_uniq_fulfillment_processor uniq_code
    @fulfillment_processors ||= {}
    !@fulfillment_processors[uniq_code]
  end

  def verify_fulfillment_module mod
    return false unless mod.respond_to?(:process)
    true
  end

  def install_fulfillment_processor uniq_code, mod
    @fulfillment_processors ||= {}
    @fulfillment_processors[uniq_code] = mod
  end

end
