class Office::OptionSetsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def create
    @product = Product.find(params[:product_id])
    @option_set = @product.option_sets.create(params[:option_set])

    # all of the old variations are now missing a set
    @product.variations.clear
  end

  def destroy
    @option_set = OptionSet.find(params[:id])
    @option_set.destroy
  end

end
