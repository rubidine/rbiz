context 'A coupon discounting all of a particular item' do
  setup do
    CartLib.activate_test_stubs

    @p = create_product(:name=>'a', :sku=>'a', :price=>17, :unlimited_quantity=>true)

    @c = Coupon.new(
           :discount_price => 7,
           :applies_all_associated => true,
           :effective_on => Date.today - 7,
           :code => 'cpn'
         )
    @c.associated_products << @p
    @c.save!

    @crt = Cart.new
    @not_p = create_product(:name=>'b',:sku=>'b',:price=>20,:unlimited_quantity=>true)
  end

  specify 'does not apply if product not in cart' do
    assert !@c.applies_to?(@crt)
  end

  specify 'applies on a cart with a single instace of the product' do
    @li = @crt.line_items.build :quantity => 1, :product => @p
    assert @c.applies_to?(@crt)
  end

  specify 'has the specified discount for a single item' do
    @li = @crt.line_items.build :quantity => 1, :product => @p
    assert_equal 700, @c.discount_for_fixed(@crt)
  end

  specify 'applies on a cart for item quantity > 1 ' do
    @li = @crt.line_items.build :quantity => 2, :product => @p
    assert @c.applies_to?(@crt)
  end

  specify 'has the specified discount for item quantity > 1' do
    @li = @crt.line_items.build :quantity => 2, :product => @p
    assert_equal 14.00, @c.discount_for(@crt)
  end
  
  specify 'should have no end' do 
    assert @c.no_end?
  end
  
  specify 'should accept setting noend to nonzero and back' do
    assert @c.no_end = 3, true
    assert @c.no_end = 0, false
  end
end

context 'A coupon discounting max of a particular item' do
  setup do
    CartLib.activate_test_stubs

    @p = create_product(:name=>'a', :sku=>'a', :price=>17, :unlimited_quantity=>true)
    @p1 = create_product(:name=>'b',:sku=>'b',:price=>20,:unlimited_quantity=>true)
                                     
    @c = Coupon.new(
           :discount_percent => 100,
           :applies_max_associated => true,
           :effective_on => Date.today - 7,
           :code => 'cpn'
         )
    @c.associated_products << @p
    @c.associated_products << @p1
    @c.save!

    @crt = Cart.new
  end

  specify 'should be invalid unless an associated product is in cart' do
    assert !@c.applies_to?(@crt)
  end

  specify 'should be valid if at least one associted item is in cart' do
    @li = @crt.line_items.build :quantity => 1, :product => @p
    assert @c.applies_to?(@crt)

    @crt.line_items.clear

    @li = @crt.line_items.build :quantity => 1, :product => @p1
    assert @c.applies_to?(@crt)
  end

  specify 'should discount from the maximum individual product' do
    @li = @crt.line_items.build :quantity => 1, :product => @p
    @li = @crt.line_items.build :quantity => 1, :product => @p1
    assert_equal @p1.price_fixed, @c.discount_for_fixed(@crt)
  end

  specify 'should not double discount if quantity of max item is 2' do
    @li = @crt.line_items.build :quantity => 2, :product => @p
    @li = @crt.line_items.build :quantity => 2, :product => @p1
    assert_equal @p1.price_fixed, @c.discount_for_fixed(@crt)
  end

  specify 'should discount entire @line if discount_entire_line is set' do
    @li = @crt.line_items.build :quantity => 2, :product => @p
    @li = @crt.line_items.build :quantity => 2, :product => @p1
    @c.discount_entire_line = true
    assert_equal (@p1.price_fixed * 2), @c.discount_for_fixed(@crt)
  end
end

context 'A Coupon discounting max_equal_lesser_associated' do
  setup do
    @p = create_product(:unlimited_quantity => true, :price => 17, :sku => 'a')
    @p1 = create_product(:name => 'b', :sku => 'b', :price=>20, :unlimited_quantity => true)
    @p2 = create_product(:name => 'c', :sku => 'c', :price => 12, :unlimited_quantity => true)

    @c = Coupon.new(
           :discount_percent => 100,
           :applies_max_equal_lesser_associated => true,
           :effective_on => Date.today - 7,
           :requires_any => true,
           :code => 'cpn'
         )

    @c.required_products << @p
    @c.associated_products << @p1
    @c.associated_products << @p2
    @c.save!

    @crt = create_cart
  end

  specify 'is invalid unless marked as having required products' do
    @c.requires_any = false
    @c.required_products.clear
    assert !@c.valid?
  end

  specify 'doesnt apply if only a required product is in cart' do
    @crt.line_items.build(:quantity=>1, :product=>@p)
    assert !@c.applies_to?(@crt)
  end

  specify 'doesnt apply if only an associated product is in cart' do
    @crt.line_items.build(:quantity=>1, :product=>@p1)
    assert !@c.applies_to?(@crt)
  end

  specify 'doesnt apply if associated product price > required products' do
    @crt.line_items.build(:quantity=>1, :product=>@p)
    @crt.line_items.build(:quantity=>1, :product=>@p1)
    assert !@c.applies_to?(@crt)
  end

  specify 'applies if has required product and has associated less then req' do
    @crt.line_items.build(:quantity=>1, :product=>@p)
    @crt.line_items.build(:quantity=>1, :product=>@p2)
    assert @c.applies_to?(@crt)
  end

  specify 'discounts the proper product when less-than' do
    @crt.line_items.build(:quantity=>1, :product=>@p)
    @crt.line_items.build(:quantity=>1, :product=>@p1)
    @crt.line_items.build(:quantity=>1, :product=>@p2)
    assert_equal @p2.price_fixed, @c.discount_for_fixed(@crt)
  end

  specify 'discounts the proper product when equal' do
    @p1.update_attribute(:price, @p.price)
    @crt.add(@p)
    @crt.add(@p1)
    @crt.add(@p2)
    assert_equal @p.price_fixed, @c.discount_for_fixed(@crt)
  end
  
  specify 'should create double @lines' do
    assert !@c.double_line?
    @c.double_line = true
    @c.create_double_lines_for(@crt)
    assert @c.double_line?
  end

  specify 'should @list required SKUs' do
    assert_equal @c.require_skus, 'a'
  end

  specify 'should accept a require SKU' do
    @c.require_skus = 'b' 
    assert_equal @c.require_skus, 'b'
  end
  
  specify 'should throw an error on a bad require sku' do
    @c.require_skus= 'bad'
    assert_equal @c.errors.full_messages, ["Require skus unknown sku `bad`"]
  end
  
  specify 'should @list associate SKUs' do
    assert_equal @c.associate_skus, "b\nc"
  end
  
  specify 'should accept an associate SKU' do
    @c.associate_skus= 'a'
    assert_equal @c.associate_skus, "a"
  end
  
  specify 'should throw an error on a bad associate sku' do
    @c.associate_skus= 'bad'
    assert_equal @c.errors.full_messages, ["Associate skus unknown sku `bad`"]
  end
end

context 'A Coupon with double_line' do
  setup do
    @crt = create_cart
    @p = create_product
    
    @c = Coupon.new(
           :effective_on => Date.today - 7,
           :requires_any => true,
           :code => 'cpn'
         )

    @c.required_products << @p
    @c.double_line = true
    @c.buy_this_many = 1
    @c.get_this_many = 1
    @c.discount_percent = 100
    @c.save!

    #@line_item = LineItem.new(:coupon_line => @c, :cart => @crt, :quantity => 1)
    
  end

  specify 'should create double @lines for cart' do
    @c.create_double_lines_for @crt
    #assert_equal '',
  end
end




# TODO
#  test validations
#  add a discount_price test to each of applies* tests

context 'A coupon that requires all' do
  setup do
    @p = create_product(:name=>'a', :sku=>'a', :price=>1, :unlimited_quantity=>true)
    @p2 = create_product(:name=>'b', :sku=>'b', :price=>1, :unlimited_quantity=>true)

    @c = Coupon.new(
            :requires_all => true,
            :discount_percent => 100,
            :effective_on => Date.today - 7,
            :code => 'cpn'
            )
            
    @c.required_products << @p

    @crt = Cart.new
  end
  it 'should fail if there is nothing in the cart' do
    assert !@c.applies_to?(@crt)
  end
  
  it 'should apply if the cart has exactly what is required' do
    @crt.line_items.build :product => @p
    assert @c.applies_to?(@crt)
  end
  
  it 'should fail if the cart only has part of what is required' do
    @crt.line_items.build :product => @p
    @c.required_products << @p2
    assert !@c.applies_to?(@crt)
  end
  
  it 'should apply if exact matches for more than one product' do
    @crt.line_items.build :product => @p
    @c.required_products << @p2
    @crt.line_items.build :product => @p2
    assert @c.applies_to?(@crt)
  end
  
  it 'should apply if cart has more than is required' do
    @crt.line_items.build :product => @p
    @c.required_products << @p2
    @crt.line_items.build :product => @p2
    @c.required_products.delete @p
    assert @c.applies_to?(@crt)
  end
end

context 'A coupon that requires any product' do
  setup do
    @p = create_product(:name=>'a', :sku=>'a', :price=>1, :unlimited_quantity => true)
    @p2 = create_product(:name=>'b', :sku=>'b', :price=>1, :unlimited_quantity => true)

    @c = Coupon.new(
            :requires_any => true,
            :discount_percent => 100,
            :effective_on => Date.today - 7,
            :code => 'cpn'
            )

    @c.required_products << @p

    @crt = create_cart
  end
  
  it 'fails if there is nothing in the cart' do
    assert !@c.applies_to?(@crt)
  end
  
  it 'passes if the cart has exactly what is required' do
    @crt.line_items.build :product => @p
    assert @c.applies_to?(@crt)
  end
  
  it 'applies if the cart with one required matches req-list w/ more than one product' do
    @crt.line_items.build :product => @p
    @c.required_products << @p2
    assert @c.applies_to?(@crt)
  end
  
  it 'applies because a full match is still a match' do
    @crt.line_items.build :product => @p
    @c.required_products << @p2
    @crt.line_items.build :product => @p2
    assert @c.applies_to?(@crt)
  end
end

context 'Coupon that requires distinct count' do
  setup do
    @p = create_product(:name => 'a', :sku => 'skua', :price => 1, :unlimited_quantity => true)
    @p2 = create_product(:name => 'b', :sku => 'skub', :price => 1, :unlimited_quantity => true)
    @p3 = create_product(:name => 'c', :sku => 'skuc', :price => 1, :unlimited_quantity => true)
    
    @c = Coupon.new(
            :requires_distinct_count => 2,
            :discount_percent => 100,
            :effective_on => Date.today - 7,
            :code => 'cpn'
            )
    @c.required_products << @p
    @c.required_products << @p2
    @c.required_products << @p3

    @crt = create_cart
  end
  
  it 'should not apply to an empty cart' do
    assert !@c.applies_to?(@crt)
  end


  it 'should not apply if there are too few products' do
    @crt.line_items.build :product =>@p, :quantity => 1
    assert !@c.applies_to?(@crt)
  end
  
  it 'should apply if there are just enough' do                                                                                                                          
    @crt.line_items.build :product =>@p, :quantity => 1
    @crt.line_items.build :product =>@p2, :quantity => 1
    assert @c.applies_to?(@crt)
  end

  it 'should apply if there are more than enough' do
    @crt.line_items.build :product =>@p, :quantity => 1
    @crt.line_items.build :product =>@p2, :quantity => 1
    @crt.line_items.build :product =>@p3, :quantity => 1
    assert @c.applies_to?(@crt)
  end
end

context 'A coupon that requires a total count' do
  setup do  
    @p = create_product(:name => 'a', :sku => 'skua', :price => 1, :unlimited_quantity => true)
    @p2 = create_product(:name => 'b', :sku => 'skub', :price => 1, :unlimited_quantity => true)

    @c = Coupon.new(
        :requires_total_count => 3,
        :discount_percent => 100,
        :effective_on => Date.today - 7,
        :code => 'cpn'
        )

    @c.required_products << @p
    @c.required_products << @p2

    @crt = create_cart
    
    @li1 = LineItem.create(:quantity => 3, :product => @p, :cart => @crt)
    @li2 = LineItem.create(:product => @p2, :quantity => 1, :cart => @crt)
  end
  
  it 'should not apply to an empty cart' do
    @li1.quantity = 0
    @li2.quantity = 0
    assert !@c.applies_to?(@crt)
  end

  it 'should not apply if there are too few products' do
    @li1.quantity = 1
    @li2.quantity = 1
    assert !@c.applies_to?(@crt)
  end

  it 'should apply if there are enough of one' do
    @li1.quantity = 3
    @li2.quantity = 0
    assert @c.applies_to?(@crt)
  end

  it 'should apply if there is more than enough of one' do
    @li1.quantity = 0
    @li2.quantity = 9000
    assert @c.applies_to?(@crt)
  end

  it 'should apply if enough of multiple' do
    @li1.quantity = 2
    @li2.quantity = 1
    assert @c.applies_to?(@crt)
  end

  it 'should apply if more than enough of multiple' do
    @li1.quantity = 10
    @li2.quantity = 90
    assert @c.applies_to?(@crt)
  end
end

context 'A coupon that requires a minimum purchase' do
  setup do  
    @p = create_product(:name => 'a', :sku => 'skua', :price => 1, :unlimited_quantity => true)
    @p2 = create_product(:name => 'b', :sku => 'skub', :price => 1, :unlimited_quantity => true)

    @c = Coupon.new(
            :requires_minimum_purchase => 20,
            :discount_percent => 100,
            :effective_on => Date.today - 7,
            :code => 'cpn'
            )
    @c.required_products << @p
    @c.required_products << @p2

    @crt = create_cart
    
    @li1 = LineItem.create(:quantity => 3, :product => @p, :cart => @crt)
    @li2 = LineItem.create(:product => @p2, :quantity => 1, :cart => @crt)
  end
  
  it "doesn't apply to an empty cart" do
    @li1.quantity = 0
    @li2.quantity = 0
    assert !@c.applies_to?(@crt)
  end

  it "doesn't apply if too few of one product" do
    @li1.quantity = 3
    assert !@c.applies_to?(@crt)
  end

  it "doesn't apply if too few of  too few of multiple" do
    @li2.quantity = 1
    @li1.quantity = 1
    assert !@c.applies_to?(@crt)
  end
  
  it "applies if enough of one" do
    @li2.quantity = 0
    @li1.quantity = 20
    assert @c.applies_to?(@crt)
  end

  it "applies if enough of multiple" do
    @li1.quantity = 20
    @li2.quantity = 20
    assert @c.applies_to?(@crt)
  end

  it "applies if more than enough of one" do
    @li2.quantity = 0
    @li1.quantity = 30
    assert @c.applies_to?(@crt)
  
    @li1.quantity = 0
    @li2.quantity = 1_000
    assert @c.applies_to?(@crt)
  end
    
  it "applies if more than enough of multiple" do
    @li1.quantity = 2_000
    @li2.quantity = 1_000    
    assert @c.applies_to?(@crt)
  end
  
  it "is not triggered on non-required product" do
    @li1.quantity = 1
    @li2.quantity = 2
    @p3 = create_product(:name=>'c', :sku=>'c', :price=>300, :quantity=>90)
    assert !@c.applies_to?(@crt)
  end
end

context "A coupon that requires distinct count" do
  setup do
    @p = create_product(:name=>'a', :sku=>'a', :price=>5)
    @p2 = create_product(:name=>'b', :sku=>'b', :price=>5)

    @c = Coupon.new(
      :requires_distinct_count => 2,
      :code => 'cpn',
      :effective_on => Date.today - 7
      )

    @crt = create_cart
  end
  
  it 'should not apply to an empty cart' do
    assert !@c.applies_to?(@crt)
  end

  it 'should not apply if there are not enough product' do
    @crt.line_items.build :product =>@p, :quantity => 1
    assert !@c.applies_to?(@crt)

    @crt.line_items.build :product => @p2, :quantity => 1
    assert @c.applies_to?(@crt)
  end
    
  it 'should fail on enough quantity, but not distinct' do
    @crt.line_items.clear
    @crt.line_items.build :product => @p, :quantity => 2
    assert !@c.applies_to?(@crt)
  end
end

context 'A coupon that requires total count and no required products' do
  setup do
    @p = create_product( :name=>'a', :sku=>'a', :price=>1, :unlimited_quantity => true)
    @p2 = create_product( :name=>'b', :sku=>'b', :price=>1, :unlimited_quantity => true)

    @c = Coupon.new(
      :requires_total_count => 2,
      :code => 'cpn',
      :effective_on => Date.today - 7
    )

    @crt = Cart.new
  end
  
  it 'should fail on empty cart' do
    assert !@c.applies_to?(@crt)
  end

  it 'should fails when too few products' do
    @li1 = @crt.line_items.build :product => @p, :quantity => 1
    assert !@c.applies_to?(@crt)
  end

  it 'should apply when enough of one' do
    @li1 = @crt.line_items.build :product => @p, :quantity => 2
    assert @c.applies_to?(@crt)
  end

  it 'should apply when more than enough of one' do
    @li1 = @crt.line_items.build :product => @p, :quantity => 3
    assert @c.applies_to?(@crt)
  end
  
  it 'should apply when enough of multiple / one of each' do
    @li1 = @crt.line_items.build :product => @p, :quantity => 1
    @li2 = @crt.line_items.build :product =>  @p2, :quantity => 1
    assert @c.applies_to?(@crt)
  end

  it 'should apply when more than enough of multiple' do
    @li1 = @crt.line_items.build :product => @p, :quantity => 1
    @li2 = @crt.line_items.build :product =>  @p2, :quantity => 1
    assert @c.applies_to?(@crt)
    @li2.quantity = 2
    assert @c.applies_to?(@crt)
    @li1.quantity = 1
    assert @c.applies_to?(@crt)
  end
end

context 'A coupon with minimum purchase, no required products' do
  setup do
    @p = create_product(:name=>'a', :sku=>'a', :price=>5, :unlimited_quantity=>true)
    @p2 = create_product(:name=>'b', :sku=>'b', :price=>10, :unlimited_quantity=>true)

    @c = Coupon.new(
      :requires_minimum_purchase => 20,
      :code => 'cpn',
      :effective_on => Date.today - 7
      )

    @crt = create_cart
    @li1 = @crt.line_items.build :product => @p, :quantity => 3
    @li2 = @crt.line_items.build :product => @p2, :quantity => 1
  end
  
  it 'should not apply to an empty cart' do
    @li1.quantity = 0
    assert !@c.applies_to?(@crt)
  end
  
  it 'should not apply when there is too few of one' do
    @li2.quantity = 0
    assert !@c.applies_to?(@crt)
  end

  it 'should not apply when there is too few of multiple' do
    @li1.quantity = 1
    assert !@c.applies_to?(@crt)
  end
  
  it 'should apply when there is enough of one' do
    @li1.quantity = 4
    @li2.quantity = 0
#    @crt.clear_cost_info!
    assert @c.applies_to?(@crt)
  end
  
  it 'should apply when ther eis enough of multiple' do
    @li1.quantity = 4
    @li2.quantity = 2
    assert @c.applies_to?(@crt)
  end
  
  it 'should apply when there is more than enough of one' do
    @li1.quantity = 30
    @li2.quantity = 0
    assert @c.applies_to?(@crt)

    @li1.quantity = 0
    @li2.quantity = 1_000
    assert @c.applies_to?(@crt)
  end
  it 'should apply when there is more than enough of multiple' do
    @li1.quantity = 30
    @li2.quantity = 1000
    assert @c.applies_to?(@crt)
  end
end

context 'A coupon with applies on all required' do
  setup do
    @p = create_product(:price => 100, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_all => true,
          :applies_all_required => true,
          :discount_percent => 50,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @p

    @crt = create_cart
    @crt.line_items.build :product => @p, :quantity => 1
    
  end
  it 'should apply to the required product' do
    assert @c.applies_to?(@crt)

    assert_equal 5000, @c.discount_for_fixed(@crt)
    assert_equal 50.0, @c.discount_for(@crt)

    @crt.line_items.first.quantity = 2
    assert_equal 10000, @c.discount_for_fixed(@crt)
    assert_equal 100.0, @c.discount_for(@crt)
  end
  
  it 'should not apply to nonrequired product' do
    @crt.line_items.first.quantity = 2
    @pppp = create_product(:price => 800, :name => 'z', :sku => 'z', :quantity => 10)
    @crt.line_items.build :product => @pppp
    assert_equal 10000, @c.discount_for_fixed(@crt)
    assert_equal 100.0, @c.discount_for(@crt)
  end
end

context 'A coupon with All Assciated' do
  setup do
    @p3 = create_product( :price => 10, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)
    @p4 = create_product( :price => 20, :sku => 'asdf4', :name => 'sdf4', :unlimited_quantity => true)

    @c = Coupon.new(
          :applies_all_associated => true,
          :discount_percent => 50,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.associated_products << @p3
    @c.associated_products << @p4

    @crt = Cart.new

  end
  it 'should not apply to empty cart' do
    assert !@c.applies_to?(@crt)
  end
  it 'should properly calculate discounts' do
    @crt.line_items.build :product => @p3, :quantity => 1
    @crt.line_items.build :product => @p4, :quantity => 1

    assert_equal 1500, @c.discount_for_fixed(@crt)
    assert_equal 15.0, @c.discount_for(@crt)
  end
end

context 'A couple with applies_total' do
  setup do
    @p4 = create_product( :price => 20, :sku => 'asdf4', :name => 'sdf4', :unlimited_quantity => true)

    @c = Coupon.new(
          :applies_total => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )

    @crt = Cart.new
    @li = @crt.line_items.build :product => @p4, :quantity => 1
  end
  it 'applies to empty cart' do
    @li.quantity = 0
    assert @c.applies_to?(@crt)
  end
  it 'should properly calculate discount on a product' do
    @li.quantity = 1

    assert_equal 200, @c.discount_for_fixed(@crt)
    assert_equal 2.0, @c.discount_for(@crt)

    @li.quantity = 2
    assert_equal 400, @c.discount_for_fixed(@crt)
    assert_equal 4.0, @c.discount_for(@crt)
  end
end

context 'A coupon with applies_max_required' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_all => true,
          :applies_max_required => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @p
    @c.required_products << @p2

    @crt = Cart.new
    @crt.line_items.build :product => @p, :quantity => 1
    @crt.line_items.build :product => @p2, :quantity => 1
  end
  it 'should apply to empty cart' do
    assert @c.applies_to?(@crt)
  end
  it 'should properly calculate discount' do
    assert_equal 700, @c.discount_for_fixed(@crt)
    assert_equal 7.0, @c.discount_for(@crt)
  end
end
  
context 'A coupon with applies_max_associated' do
  setup do
    @p3 = create_product( :price => 30, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)
    @p4 = create_product( :price => 60, :sku => 'asdf4', :name => 'sdf4', :unlimited_quantity => true)

    @c = Coupon.new(
          :applies_max_associated => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.associated_products << @p3
    @c.associated_products << @p4

    @crt = Cart.new
    @crt.line_items.build :product => @p3, :quantity => 1
  end
  it 'should properly calculate discount' do
    assert_equal 300, @c.discount_for_fixed(@crt)
    assert_equal 3.0, @c.discount_for(@crt)

    @crt.line_items.build :product => @p4, :quantity => 1
    assert_equal 600, @c.discount_for_fixed(@crt)
    assert_equal 6.0, @c.discount_for(@crt)
  end
end

context 'A coupon with applies_max_equal_lesser_required' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)
    @p3 = create_product( :price => 20, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_any => true,
          :applies_max_equal_lesser_required => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @p
    @c.required_products << @p2
    @c.required_products << @p3

    @crt = Cart.new
    @crt.line_items.build :product => @p, :quantity => 1
    @li = @crt.line_items.build :product => @p2, :quantity => 1
  end
  it 'should apply to empty cart' do
    assert @c.applies_to?(@crt)
  end
  it 'should properly caluculate discount' do
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  it 'should, despite quantity, only apply based on product price' do
    @crt.line_items.build :product => @p3, :quantity => 7
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  it 'should only apply to one instance of the product' do
    @crt.line_items.build :product => @p3, :quantity => 7
    @li.quantity = 3
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
end

context 'A coupon with applies_max_equal_lesser_associated' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)
    @p3 = create_product( :price => 20, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)
    
    @rp = create_product( :price => 60, :sku => 'asdf4', :name => 'sdf4', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_any => true,
          :applies_max_equal_lesser_associated => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @rp
    @c.associated_products << @p
    @c.associated_products << @p2
    @c.associated_products << @p3

    @crt = Cart.new
    @crt.line_items.build :product => @rp, :quantity => 1
    @li = @crt.line_items.build :product => @p2, :quantity => 1
  end
  it 'should apply to empty cart' do
    assert @c.applies_to?(@crt)
  end
  
  it 'should calculate discount' do
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  
  it 'should despite quantity, only apply based on product price' do
    @crt.line_items.build :product => @p3, :quantity => 7
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end

  it 'should only apply to one instance of the product' do
    @crt.line_items.build :product => @p3, :quantity => 7
    @li.quantity = 3
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  
  it 'should not apply to things that are too expensive' do
    @crt.line_items.build :product => @p3, :quantity => 7
    @li.quantity = 3
    @crt.line_items.build :product => @p, :quantity => 1
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
end

context 'A coupon with :applies_max_equal_lesser_other' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)
    @p3 = create_product( :price => 20, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)
    
    @rp = create_product( :price => 60, :sku => 'asdf4', :name => 'sdf4', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_any => true,
          :applies_max_equal_lesser_other => true,
          :discount_percent => 10,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @rp

    @crt = Cart.new
    @crt.line_items.build :product => @rp, :quantity => 1
    
    @li = @crt.line_items.build :product => @p2, :quantity => 1
  end
  it 'should apply to empty cart' do
    @li.quantity = 0
    assert @c.applies_to?(@crt)
  end
  it 'should calculate discount' do
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  it 'should, despite quantity, only apply based on product price' do 
    @crt.line_items.build :product => @p3, :quantity => 7
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  it 'should only apply to one instance of the product' do
    @crt.line_items.build :product => @p3, :quantity => 7
    @li.quantity = 3
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
  it 'should not apply to things that are too expensive' do
    @crt.line_items.build :product => @p3, :quantity => 7
    @li.quantity = 3
    @crt.line_items.build :product => @p, :quantity => 1
    assert_equal 500, @c.discount_for_fixed(@crt)
    assert_equal 5.0, @c.discount_for(@crt)
  end
end

context 'A coupon with applies to shipping' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)
    @p3 = create_product( :price => 20, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_any => true,
          :discount_percent => 10,
          :applies_shipping => true,
          :code => 'test',
          :effective_on => Date.today - 7
        )
    @c.required_products << @p
    @c.required_products << @p2
    @c.required_products << @p3

    @crt = Cart.new(:shipping_price_fixed => 1500)
    @crt.line_items.build :product => @p, :quantity => 1
    @li = @crt.line_items.build :product => @p2, :quantity => 1
  end
  it 'should apply to empty cart' do
    @li.quantity = 0
    assert @c.applies_to?(@crt)
  end
  it 'should apply to a filled cart' do
    @li.quantity = 1
    assert @c.applies_to?(@crt)
    assert_equal @c.discount_for_fixed(@crt), 150
  end
end


context 'A coupon' do
  setup do
    @p = create_product( :price => 70, :sku => 'asdf', :name => 'sdf', :unlimited_quantity => true)
    @p2 = create_product( :price => 50, :sku => 'asdf2', :name => 'sdf2', :unlimited_quantity => true)
    @p3 = create_product( :price => 20, :sku => 'asdf3', :name => 'sdf3', :unlimited_quantity => true)

    @c = Coupon.new(
          :requires_any => true,
          :discount_percent => 10,
          :applies_shipping => true,
          :code => 'test',
          :double_line => true,
          :effective_on => Date.today - 7
        )
    @c.required_products << @p
    @c.required_products << @p2
    @c.required_products << @p3

    @crt = Cart.new(:shipping_price_fixed => 1500)
    @li = @crt.line_items.build :product => @p1, :quantity => 1
    @li2 = @crt.line_items.build :product => @p2, :quantity => 1
     @li3 = @crt.line_items.build :product => @p3, :quantity => 1
  end
  it 'should apply to empty cart' do
    puts @c.create_double_lines_for @crt 
    #assert_equal , []
  end
end
