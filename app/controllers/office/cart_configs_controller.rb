class Office::CartConfigsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def index
    @cart_configs = CartConfig.find(
                      :all,
                      :select => '*,value as serial_value',
                      :order => 'scope, name'
                    )
  end

  def update
    @cart_config = CartConfig.find(params[:id])
    @cart_config.update_attribute(:value, params[:cart_config][:value])
  end

end
