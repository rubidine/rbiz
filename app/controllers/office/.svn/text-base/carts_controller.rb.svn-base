class Office::CartsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def index
    @carts = Cart.paginate(
               :conditions => ['sold_at IS NOT NULL'],
               :order => 'sold_at desc',
               :readonly => true,
               :page => (params[:page] || 1).to_i,
               :per_page => (
                 params[:perpage] ||
                 CartConfig.get(:products_per_page, :office) |
                 30
               )
             )
  end
end
