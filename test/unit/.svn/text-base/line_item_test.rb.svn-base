context 'The LineItem class' do
  setup do
    @product = create_product
    @customer = create_customer
    @cart = create_cart(:customer => @customer)
  end

  it 'should create valid line item for custom price products' do
    inst = LineItem.create(
      :custom_price =>  13.50, :quantity => 1, :cart => @cart
           )
    inst.valid?
    assert inst.valid?, inst.errors.full_messages.inspect
  end

  it 'should create valid line item for product with sufficient quantity' do
    inst = LineItem.create(:product => @product, :quantity => 1, :cart => @cart)
    assert inst.valid?
  end

  it 'should not create a line item if a product is unavailable' do
    @product.destroy
    prod = create_product(:effective_on => Date.today + 3)
    inst = LineItem.create(:product => prod, :quantity => 1, :cart => @cart)
    assert inst.new_record?
  end

  it 'should not create a line item if a product quantity is too low' do
    inst = LineItem.create(:product => @product, :quantity => 500, :cart => @cart)
    assert inst.new_record?
  end

end

context 'Any line item' do
  setup do
    @cart = create_cart
    @line_item = LineItem.new(:cart => @cart, :quantity => 1)
    @product = create_product
  end

  it 'should fail validation if neither a product or custom price is specified' do
    assert !@line_item.valid?
  end

  it 'should fail validation if both a product and custom price are specified' do
    @line_item.custom_price = 13.50
    @line_item.product = @product
    assert !@line_item.valid?
  end

  it 'should pass validation if a product is specified' do
    @line_item.product = @product
    assert_valid @line_item
  end

  it 'should pass validation if a custom price is specified' do
    @line_item.custom_price = 13.50
    assert @line_item.valid?
  end

  it 'should not change product associated with it (unless it backs out quantity committment [NOT IMPL])' do
    p2 = Product.new                                                             
    @line_item.product = @product
    @line_item.product = p2
    assert_equal @product, @line_item.product
  end

end


context 'A custom line item' do
  setup do
    @cart = Cart.new
    @line_item = LineItem.create(
                   :custom_price => 13.50, :quantity => 2, :cart => @cart,
                   :custom_description => 'TEST DESCRIPTION', :custom_weight => 3.5
                 )
  end

  it 'should be custom?' do
    assert @line_item.custom?
  end

  it 'should return the custom price' do
    assert_equal 13.50, @line_item.individual_price
    assert_equal 1350, @line_item.individual_price_fixed
  end

  it 'should return the custom price times quantity for total price' do
    assert_equal 27.00, @line_item.price
    assert_equal 2700, @line_item.price_fixed
  end

  it 'should return custom description for the name' do
    assert_equal 'TEST DESCRIPTION', @line_item.name
  end

  it 'should return the individual weight' do
    assert_equal @line_item.individual_weight, 3.5
  end
  
  it 'should return the total weight as weight x quantity' do
    assert_equal @line_item.weight, 7
  end
  
end

context 'A product based line item' do

  setup do
    @cart = create_cart
    @limited_product = create_product(:price => 7.25, :weight => 3.6, 
                            :quantity => 10)
    @limited_line_item = LineItem.create(
                   :quantity => 2, :product => @limited_product, :cart => @cart
                 )

    @unlimited_product = create_unlimited_product(:price => 7.25)
    @unlimited_line_item = LineItem.create(
                             :quantity => 2, :product => @unlimited_product,
                             :cart => @cart
                           )
  end

  it 'should not be custom?' do
    assert !@limited_line_item.custom?
  end

  it 'should return the product price' do
    assert_equal 7.25, @limited_line_item.individual_price
    assert_equal 725, @limited_line_item.individual_price_fixed
  end

  it 'should return product price times quantity for total price' do
    assert_equal 14.50, @limited_line_item.price
    assert_equal 1450, @limited_line_item.price_fixed
  end

  it 'should change quantity of committment when added to cart' do
    assert_equal 2, @limited_product.quantity_committed
    assert_equal 2, @limited_line_item.quantity_reservations_count
  end

  it 'should revert quantity of commitment when removed from cart' do
    @limited_line_item.update_quantity 1
    assert_equal 1, @limited_product.quantity_committed
    assert_equal 1, @limited_line_item.quantity_reservations_count
  end

  it 'should not change quantity of committment when umlimited quantity available' do
    assert_equal 0, @unlimited_product.quantity_committed
  end

  it 'should decrement available quantity on sale' do
    @limited_line_item.mark_as_sold
    assert_equal 8, @limited_line_item.product.quantity
  end

  it 'should return product name for the name' do
    assert_equal @limited_product.name, @limited_line_item.name
  end
  
  it 'should return the individual weight' do
    assert_equal @limited_line_item.individual_weight, 3.6
  end
end

context 'A line item with price adjustment options' do
  setup do
    @product = Product.create!(
                 :name => 'test', :quantity => 3, :sku => 't', :price => 30.30,
                 :weight => 4.4
               )

    @option_set = OptionSet.create!(
                    :name => 'test option set',
                    :product => @product
                  )
    @option1 = Option.create!(
                 :option_set => @option_set,
                 :name => 'test opt',
                 :sku_extension => '-01'
               )
    @option2 = Option.create!(
                 :option_set => @option_set, :name => 'test opt 2',
                 :has_input => true, :price_adjustment => 0.30
               )
    
    @product_option_selection = ProductOptionSelection.new(
                                  :product => @product,
                                  :quantity => 10,
                                  :quantity_committed => 0
                                )
    @product_option_selection.options << @option1
    @product_option_selection.save

    @line_item = LineItem.new(
                   :cart => Cart.new,
                   :product => @product,
                   :product_option_selection => @product_option_selection,
                   :quantity => 2
                 )

    @product_option_selection2 = ProductOptionSelection.new(
                                   :product => @product,
                                   :unlimited_quantity => true,
                                   :quantity_committed => 0
                                 )
    @product_option_selection2.options << @option2
    @product_option_selection2.save
    
    @option_specification2 = OptionSpecification.create!(
                              :option => @option2,
                              :option_text => 'WOO'
                            )
    @line_item_spec2 = LineItem.new(
                        :cart => Cart.new,
                        :product => @product,
                        :product_option_selection => @product_option_selection2,
                        :quantity => 2
                      )
    @line_item_spec2.option_specifications << @option_specification2
  end

  it 'should return a full sku with all the options' do
    assert_equal 't-test option set=test opt 2', @line_item_spec2.full_sku 
  end

  it 'should append sku_extension on options that specify them' do
    assert_equal 't-01', @line_item.full_sku 
  end

  it 'should store an option specification for each option requesting it' do
    assert_equal 1, @line_item_spec2.option_specifications.length
  end

  it 'should store quantity committed on the option selection' do
    @line_item.quantity = 7
    assert_equal 7, @line_item.product_option_selection.quantity_committed
  end

  it 'should adjust price based on options' do
    assert_equal 30.60, @line_item_spec2.individual_price
    assert_equal 3060, @line_item_spec2.individual_price_fixed
  end
  
  it 'should decrement available quantity on sale' do
    @line_item.mark_as_sold
    assert_equal 8, @line_item.product_option_selection.quantity
  end
  
  it 'should block changing an already set product id' do
    @previous_id = @line_item.product_id
    @line_item.product_id = '12345'
    assert_equal @line_item.product_id, @previous_id
  end

  it 'should return specifications' do
    assert_equal @line_item_spec2.specifications, "test opt 2 = WOO"
  end
end

context 'A line item with weight adjustment options' do
  setup do
    @product = Product.create!(
                 :name => 'test', :quantity => 3, :sku => 't', :price => 30.30,
                 :weight => 4.4
               )

    @option_set = OptionSet.create!(
                    :name => 'test option set',
                    :product => @product
                  )
    @option3 = Option.create!(
                 :option_set => @option_set, :name => 'test opt 3',
                 :has_input => true, :weight_adjustment => 0.10
               )
    
    @product_option_selection = ProductOptionSelection.new(
                                  :product => @product,
                                  :quantity => 10,
                                  :quantity_committed => 0
                                )

    @product_option_selection3 = ProductOptionSelection.new(
                                   :product => @product,
                                   :unlimited_quantity => true,
                                   :quantity_committed => 0
                                 )
    @product_option_selection3.options << @option3
    @product_option_selection3.save
    
    @option_specification3 = OptionSpecification.create!(
                              :option => @option3,
                              :option_text => 'WOO'
                            )
    @line_item_spec3 = LineItem.new(
                        :cart => Cart.new,
                        :product => @product,
                        :product_option_selection => @product_option_selection3,
                        :quantity => 2
                      )
    @line_item_spec3.option_specifications << @option_specification3
    
  end
  
  it 'should adjust weight based on options' do
    assert_equal 4.50, @line_item_spec3.individual_weight
  end

end

context 'A line item with no product' do
  setup do
    @cart = create_cart
    @line_item = LineItem.new(:cart => @cart, :quantity => 1)
    @product = create_product
  end

  it 'should accept a new product by the product id' do
    @line_item.product_id = @product.id
    assert_equal @line_item.product, @product
  end
end
