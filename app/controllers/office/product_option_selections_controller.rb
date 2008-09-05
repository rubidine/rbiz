class Office::ProductOptionSelectionsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def update
    @product_option_selection = ProductOptionSelection.find(params[:id])
    @product_option_selection.update_attributes(params[:product_option_selection])
    render :nothing => true
  end
end
