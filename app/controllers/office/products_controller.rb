class Office::ProductsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  # paginate through products
  def index
    @products = Product.paginate(
      :all,
      :order=>'sku asc',
      :per_page => (CartConfig.get('products_per_page', 'office') || 30),
      :page => (params[:page] || 1)
    )
  end

  # show the form to create a new product
  def new
    @product = Product.new
  end

  # create the product.  if successful, show it, otherwise show form again
  def create
    @product = Product.create(params[:product])
    if @product.new_record?
      render :action => 'new'
    else
      flash :success => 'Product Created'
      redirect_to edit_office_product_url(@product)
    end
  end

  # show a product for editing
  def edit
    @product = Product.find(
                 params[:id],
                 :include => [:product_images, :tag_activations]
               )
    @image = ProductImage.new
  end

  # edit postback
  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    if @product.save
      flash[:notice] = "Product Updated"
      redirect_to edit_office_product_url(@product)
    else
      render :action => 'edit'
    end
  end

  # delete
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to office_products_url
  end

  def available
    @product = Product.find(params[:id])
    @product.toggle_available!

    respond_to do |format|
      format.js
      format.html do
        if @product.available?
          flash[:notice] = "#{@product.name} made available."
        else
          flash[:notice] = "#{@product.name} removed from site."
        end
        redirect_to office_products_url
      end
    end
  end

  def featured
    @product = Product.find(params[:id])
    @product.toggle!(:featured)

    respond_to do |format|
      format.js
      format.html do
        if @product.featured?
          flash[:notice] = "#{@product.name} featured."
        else
          flash[:notice] = "#{@product.name} NOT featured."
        end
        redirect_to office_products_url
      end
    end
  end

  def duplicate
    opa = Product.find(params[:id]).attributes
    opa['price'] = (opa['price'] / 100.0)
    opa['msrp'] = (opa['msrp'] / 100.0) if opa['msrp']
    if opa['extra_shipping']
      opa['extra_shipping'] = (opa['extra_shipping'] / 100.0)
    end
    @product = Product.new(opa)
    render :action => 'new'
  end

  def update_matrix
    options = params[:option].collect{|x,y| y[:option_id]}
    options.reject!{|x| x.empty?}
    @matrix_entries = ProductOptionSelection.ids_for_option_ids(options)
    @matrix_entries.collect!{|x| ProductOptionSelection.find(x)}
  end

end
