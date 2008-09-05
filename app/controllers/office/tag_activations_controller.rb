class Office::TagActivationsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def create
    @product = Product.find(params[:product_id])
    tag = Tag.find(params[:tag][:id], :include => :tag_set)
    @activation = TagActivation.create(:product => @product, :tag => tag)
  end

  def destroy
    @activation = TagActivation.find(params[:id])
    @activation.destroy
  end
end
