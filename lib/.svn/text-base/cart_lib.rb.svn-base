# This is a continer for shipping and billing related methods.
# All of these methods should be overwritten by modules that are included
# to do the actual work, such as the Authorize.net module for payments and
# UPS-XML for shipping calculations.
module CartLib
  extend CartLib::PaymentMethods
  extend CartLib::ShippingMethods
  extend CartLib::FulfillmentMethods

  # The gateways for shipping / billing / fulfillment should not be
  # called up in test mode, so we stub them out.  They should have their
  # own test so should not be tested in normal tests.
  def self.activate_test_stubs
    CartLib.stubs(:compute_shipping).returns(
      [
        ShippingResponse.new(
          :success => true,
          :message => '',
          :body => '',
          :cost => 0.0,
          :plugin_name => 'test stub'
        )
      ]
    )
    CartLib.stubs(:process_payment).returns(
      PaymentResponse.new(
        :success => true,
        :message => '',
        :body => '',
        :cost => 0.0,
        :plugin_name => 'test stub'
      )
    )
    CartLib.stubs(:process_fulfillment).returns(
      FulfillmentResponse.new(
        :success => true,
        :message => '',
        :body => '',
        :cost => 0.0,
        :plugin_name => 'test stub'
      )
    )
  end

  private
  def self.log_error scope, message
    if ENV['RAILS_ENV'] == 'development'
      raise "#{scope}: #{message}"
      # not reached #
    end
    ErrorMessage.create(:scope => scope, :message => message)
    lgr = (defined?(logger) ? logger : RAILS_DEFAULT_LOGGER)
    lgr.error "\n\n XXX\n XXX #{scope}: #{message}\n XXX\n"
  end
end
