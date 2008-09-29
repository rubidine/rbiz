class Office::ProductImagesController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def create
    @image = ProductImage.create(
               params[:product_image].merge(:product_id => params[:product_id])
             )

    if @image.new_record?
      flash[:error] = "Unable to save image: " + \
                      @image.errors.full_messages.inspect
      @image.twin.destroy if @image.twin
    elsif !@image.twin
      flash[:error] = "Unable to create thumbnail.  Errors from image: " + \
                      @image.errors.full_messages.inspect
      @image.destroy
    elsif @image.twin.new_record?
      flash[:error] = "Unable to create thumbnail.  Errors from image: " + \
                      @image.errors.full_messages.inspect + \
                      "Errors from thumbnail: " + \
                      @image.twin.errors.full_messages.inspect
      @image.destroy
    else
      flash[:notice] = "Image and thumbnail created"
    end
    redirect_to edit_office_product_url(params[:product_id])
  end

  def destroy
    @image = ProductImage.find(params[:id])
    @product = @image.product

    # only destroy twins if we destroy the first without error
    @image.destroy and (@image.twin ? @image.twin.destroy : false)

    @product.cache_images!
    render :nothing => true
  end

  def reorder
    @image = ProductImage.find(params[:id])
    @product = @image.product

    new_pos = params[:image][:position].to_i
    going_up = new_pos < (@image.position || 0)
    op = going_up ? '+' : '-'
    max = [new_pos, (@image.position || 0)].max
    min = [new_pos, (@image.position || 0)].min
    @image.class.update_all(
      "position = (position #{op} 1)",
      "#{@image.scope_condition} AND position >= #{min} AND position <= #{max}"
    )
    @image.update_attribute(:position, new_pos)

    if @product.default_image_id == @image.id or new_pos == 0
      @product.cache_images!
    end
    render :nothing => true
  end
end
