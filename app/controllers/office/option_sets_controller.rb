class Office::OptionSetsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def create
    @product = Product.find(params[:product_id])
    @option_set = @product.option_sets.create(params[:option_set])

    # all of the old product option selections are now missing a set
    @product.product_option_selections.clear
  end

  def destroy
    @option_set = OptionSet.find(params[:id])
    @option_set.destroy
  end

end
