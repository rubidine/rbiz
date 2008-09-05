class Office::CustomersController < ApplicationController
  helper :cart_common
  helper :office
  layout 'office'

  def index
    @customers = Customer.paginate(
                   :page => (params[:page] || 1).to_i,
                   :per_page =>
                     (CartConfig.get(:office, :products_per_page) || 20),
                   :order => 'email'
                 )
  end
end
