class Office::CouponsController < ApplicationController

  layout 'office'
  helper :office
  helper :cart_common

  def index
    @coupons = Coupon.find(:all)
  end

  def show
    @coupon = Coupon.find params[:id]
  end

  def new
    @coupon = Coupon.new
  end

  def edit
    @coupon = Coupon.find params[:id]
    render :action => 'new'
  end

  def create
    if (@coupon = Coupon.create(params[:coupon])).new_record?
      render :action => 'new'
    else
      redirect_to :action => 'index'
    end
  end

  def update
    @coupon = Coupon.find params[:id]
    @coupon.update_attributes(params[:coupon])
    redirect_to :action => 'index'
  end

  def destroy
    @coupon = Coupon.find params[:coupon]
    @coupon.destroy
    redirect_to :action => 'index'
  end
end
