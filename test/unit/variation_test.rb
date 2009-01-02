context 'An unlimited variation' do
  setup do
    @p = create_product
    @v = create_variation(:product => @p, :unlimited_quantity => true)
  end

  specify 'reports it is unlimited' do
    assert @v.unlimited_quantity?
  end
end

context 'A variation with finite quantity' do
  setup do
    CartLib.activate_test_stubs

    @p = Product.create! :name=>'1', :sku=>'1', :price=>1, :unlimited_quantity=>true
    @v = Variation.create! :product => @p, :quantity => 3
  end

  specify 'reports it is unlimited' do
    assert !@v.unlimited_quantity?
  end
end

context 'A new variation' do
  setup do
    CartLib.activate_test_stubs

    @p = Product.create! :name=>'1', :sku=>'1', :price=>1, :unlimited_quantity=>true
    @v = Variation.create! :product => @p
  end

  specify 'defaults to unlimited without specific quantity' do
    assert @v.unlimited_quantity?
  end
end
