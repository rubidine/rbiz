context 'A Cart, in general' do
  setup do
    @customer = create_customer
    @cart = create_cart
    @product = create_product
  end

  it 'should return a line item when a product is added' do
    li = @cart.add(@product)
    assert_kind_of LineItem, li
  end

  it 'should add products through the add method (default quantity 1)' do
    li = @cart.add(@product)
    assert_equal 1, li.quantity
  end

  it 'should add products through the add method with quantity != 1' do
    quantity = 3
    li = @cart.add(@product, quantity)
    assert_equal quantity, li.quantity
  end

  it 'should NOT add products with not enough quantity' do
    quantity = 50
    li = @cart.add(@product, quantity)
    assert_kind_of FalseClass, li
  end

  it 'should NOT add unavailable (expried) products' do
    p = create_expired_product
    li = @cart.add(p)
    assert_kind_of FalseClass, li, "ADDED EXPIRED PRODUCT #{p.inspect}"
  end

  it 'should NOT add unavailable (not on market) products' do
    p = create_pending_product
    li = @cart.add(p)
    assert_kind_of FalseClass, li
  end

  it 'should set error message when unable to add a product' do
    @cart.add(@product, 50)
    assert @cart.error_message
  end
end

context 'An empty cart, a product with options' do
  setup do 
    @customer = create_customer
    @cart = create_cart
    @product = create_product
    @product_sel = create_scoped_product
    @option_set = create_option_set(:product => @product_sel)
    @option = create_option(:option_set => @option_set)
    @variation = new_variation(:product => @product_sel)
    @variation.options << @option
    @variation.save
  end

  it 'should add productsthrough the add method (default quantity)' do
    li = @cart.add(@variation)
    assert_equal 1, li.quantity
  end

  it 'should add products through the add method with quantity != 1' do
    quantity = 3
    li = @cart.add(@variation, quantity)
    assert_equal quantity, li.quantity
  end

  it 'should NOT add products with not enough quantity (tracked on option)' do
    quantity = 50
    li = @cart.add(@variation, quantity)
    assert_kind_of FalseClass, li
  end

  it 'should NOT add products with not enough quantity (tracked on product)' do
    # tell it to look on product
    @variation.update_attribute(:track_quantity_on_product, true)

    li = @cart.add(@variation, 50)
    assert_kind_of FalseClass, li
  end

end

context 'A cart with a product' do
  setup do
    @customer = create_customer
    @cart = create_cart(:customer => @customer)
    @product = create_product
    @line = @cart.add(@product)
  end

  it 'should return the existing line item when adding same product' do
    li = @cart.add(@product)
    assert_equal @line, li
  end

  it 'should add same product through the add method (default quantity 1)' do
    li = @cart.add(@product)
    assert_equal @line, li
  end

  it 'should add same products through the add method with quantity != 1' do
    li = @cart.add(@product, 2)
    assert_equal @line, li, @cart.error_message
  end

  it 'should not add same product unless enough quantity' do
    li = @cart.add(@product, 50)
    assert_kind_of FalseClass, li
  end

  it 'should be able to add all remaining quantity of a product' do
    @product.update_attribute :quantity, 12
    li = @cart.add(@product, 11)
    assert_kind_of LineItem, li, @cart.error_message
  end

  it 'should update quantity of line item with update_quantity' do
    li = @cart.update_quantity(@line.id, 3)
    assert_equal 3, li.quantity
  end

  it 'should return false if not enough quantity for update_quantity' do
    li = @cart.update_quantity(@line.id, 50)
    assert_kind_of FalseClass, li
  end

  it 'should warn if not enough quantity for update_quantity' do
    li = @cart.update_quantity(@line.id, 50)
    assert @cart.error_message
  end

  it 'should be able to update_quantity of a product to full amount' do
    @product.update_attribute :quantity, 12
    li = @cart.update_quantity(@line.id, 12)
    assert_kind_of LineItem, li, @cart.error_message
  end

  it 'should return nil if trying to update quantity of a product that doesnt exist in cart' do
    fake_line_id = -1
    li = @cart.update_quantity(fake_line_id, 7)
    assert_nil li
  end

  it 'should delete line item if update_quantity to zero' do
    li = @cart.update_quantity(@line.id, 0)
    assert_equal 0, @cart.line_items.length
  end
end

context 'A cart during checkout' do
  setup do
    @customer = create_customer
    @cart = create_cart
    @product = create_product

    @cart.stubs(:shipping_price_fixed).returns(1500)
    @cart.shipping_address = Address.create(:state => 'KY')

    CartConfig.set(:tax_rates, {'KY' => 0.06}, :payment)

    @line = @cart.add(@product)
  end

  it 'should report total price for items' do
    assert_equal 150, @cart.total_price_fixed
  end

  it 'should report tax price' do
    # 1.50 * 0.06 = 0.09
    assert_equal 9, (tp = @cart.tax_price_fixed)
  end

  it 'should have grand total of shipipng + tax + products' do
    assert_equal 1659, @cart.grand_total_fixed
  end

  it 'should discount grand total for coupon' do
    @coupon = Coupon.create(
                         :effective_on => (Date.today - 3),
                         :code => 'asdf',
                         :applies_total => true,
                         :discount_price => 3.50
                        )
    @cart.coupons << @coupon

    # removing products only leaves shipping (not taxed)
    assert_equal 1500, @cart.grand_total_fixed
  end

end

context 'A cart with a product with options and specifications' do 
  setup do 
    @customer = create_customer
    @cart = create_cart(:customer => @customer) 
    @product = create_product
    @product_sel = create_scoped_product
    @option_set = create_option_set(:product => @product_sel)
    @option = create_option(:option_set => @option_set, :has_input => true)

    @variation = new_variation(:product => @product_sel) 
    @variation.options << @option 
    @variation.save
  end 
 
  it 'should add specifications to line item when added' do 
    li = @cart.add(@variation, 1, {@option => 'TEST1'}) 
    assert_equal 1, li.option_specifications.length 
    assert_equal 'TEST1', li.option_specifications.first.option_text 
  end 
 
  it 'should update quantity of line item when adding with same specs' do 
    li = @cart.add(@variation, 1, {@option => 'TEST1'}) 
    li2 = @cart.add(@variation, 1, {@option => 'TEST1'}) 
    assert_equal li, li2
  end 
 
  it 'should make new line item when adding with different specs' do 
    @cart.add(@variation, 1, {@option => 'TEST1'}) 
    @cart.add(@variation, 1, {@option => 'NOT SAME'}) 
    assert_equal 2, @cart.line_items.length 
  end 
end 
