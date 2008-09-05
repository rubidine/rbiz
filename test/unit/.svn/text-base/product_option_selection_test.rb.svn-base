context 'An unlimited product option selection' do
  setup do
    @p = create_product
    @pos = create_product_option_selection(:product => @p, :unlimited_quantity => true)
  end

  specify 'reports it is unlimited' do
    assert @pos.unlimited_quantity?
  end
end

context 'An product option selection with finite quantity' do
  setup do
    CartLib.activate_test_stubs

    @p = Product.create! :name=>'1', :sku=>'1', :price=>1, :unlimited_quantity=>true
    @pos = ProductOptionSelection.create! :product => @p, :quantity => 3
  end

  specify 'reports it is unlimited' do
    assert !@pos.unlimited_quantity?
  end
end

context 'A new selection' do
  setup do
    CartLib.activate_test_stubs

    @p = Product.create! :name=>'1', :sku=>'1', :price=>1, :unlimited_quantity=>true
    @pos = ProductOptionSelection.create! :product => @p
  end

  specify 'defaults to unlimited without specific quantity' do
    assert @pos.unlimited_quantity?
  end
end
