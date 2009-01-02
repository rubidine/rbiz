class Office::VariationsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def update
    @variation = Variation.find(params[:id])
    @variation.update_attributes(params[:variation])
    render :nothing => true
  end
end
