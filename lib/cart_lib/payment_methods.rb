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
    if @payment_types.length == 1 and @payment_types.values.first.length == 1
      processor = @payment_types.values.first.first
      param = "#{processor.to_s.underscore}_#{@payment_types.keys.first.to_s.underscore}"
    else
      param = params[:payment][:method]
      processor = nil
      type = @payment_types.detect do |x,y|
        y.detect do |z|
          processor = z
          "#{z.to_s.underscore}_#{x.to_s.underscore}" == param
        end
      end
      unless type
        msg = "#{cart.customer.email}: Unable to find payment method '#{param}'"
        log_error "Payment", msg
        return PaymentResponse.new(
                 :success => false,
                 :message => msg,
                 :body => nil
               )
      end
    end

    param_scope = "payment_#{param}"

    # return from this
    begin
      rv = @payment_processors[processor].process(
             type,
             cart,
             params[param_scope]
           )
      unless rv.is_a?(PaymentResponse)
        msg = "Invalid response from processor #{param}: #{rv.inspect}"
        log_error "Payment", msg
        PaymentResponse.new(
          :success => false,
          :message => msg,
          :body => ''
        )
      else
        rv
      end
    rescue Exception => ex
      msg = "#{cart.customer.email}: " + 
            "Exception Caught during processing #{param}: #{ex.message}"
      log_error "Payment", msg
      PaymentResponse.new(
        :success => false,
        :message => msg,
        :body => ""
      )
    end
    # no more code, return from above line(s)
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
