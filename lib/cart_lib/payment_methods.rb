module CartLib::PaymentMethods

  def each_payment_type
    @payment_types.each do |pt, processors|
      processors.each do |processor|
        yield processor, pt
      end
    end
  end

  # Billing gateways should override this method to perform checkout, and
  # should return an instance of CartLib::PaymentResponse
  def process_payment cart, params
    # type will be 'credit_card' or something similar
    unless type = select_payment_type(params)
      msg = "#{cart.customer.email}: Unable to determine payment type"
      log_error "Payment", msg
      return PaymentResponse.new(
               :success => false,
               :message => msg,
               :body => params[:payment][:method].to_s
             )
    end

    # processors will be [AuthorizeNet] or something similar
    if (processors = select_payment_processors(type)).empty?
      msg = "#{cart.customer.email}: Unable to find payment processor"
      log_error "Payment", msg
      return PaymentResponse.new(
               :success => false,
               :message => msg,
               :body => params[:payment][:method].to_s
             )
    end

    invalid_responses = []
    first_valid_response = processors.detect do |pr|
      # can be per-processor/method
      # or global
      pm = params["#{pr.name}_#{type}"] || params[:payment]
      begin
        rv = pr.process(type, cart, pm)
      rescue Exception => ex
        msg = "#{cart.customer.email}: " + 
              "Exception Caught during processing: #{ex.message}" +
              "\n-- #{ex.backtrace.join("\n-- ")}"
        rv = PaymentResponse.new(
                :success => false,
                :message => msg,
                :body => ""
              )
        log_error "Payment", msg
      end
      invalid_responses << rv unless rv.success?
      rv.success? ? rv : nil
    end

    return first_valid_response || invalid_responses
  end

  def select_payment_type params
    if @payment_types.length == 1
      return @payment_types.keys.first
    end

    # if a selection of which payment type to use is required, it will be like:
    # 'authorize_net_credit_card'
    if param = params[:payment][:method]
      rv = @payment_types.detect do |typ,prc|
        "#{prc.to_s.underscore}_#{typ.to_s.underscore}" == param
      end
      rv = rv[0] if rv
      return rv
    end
  end

  def select_payment_processors type
    (@payment_types[type] || []).collect do |uniq_code|
      @payment_processors[uniq_code]
    end
  end

  # Payment processors call this method to install their hooks
  # module must respond to : payment_types(), process(type, cart, params)
  def register_payment_processor mod
    @payment_processors ||= {}
    uniq_code = mod.name
    return unless verify_uniq_payment_processor uniq_code
    return unless verify_payment_module mod
    install_payment_processor uniq_code, mod
  end

  private

  def verify_uniq_payment_processor uniq_code
    !@payment_processors[uniq_code]
  end

  def verify_payment_module mod
    return false unless mod.respond_to?(:payment_types)
    return false unless mod.payment_types.is_a?(Array)
    return false unless mod.respond_to?(:process)
    true
  end

  def install_payment_processor uniq_code, mod
    @payment_processors[uniq_code] = mod
    @payment_types ||= {}
    mod.payment_types.each do |pt|
      @payment_types[pt] ||= []
      @payment_types[pt] << uniq_code
    end
  end
end
