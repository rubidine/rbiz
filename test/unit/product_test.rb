context "A newly created product" do
  setup do
    CartLib.activate_test_stubs

    Product.delete_all
    OptionSet.delete_all
    Option.delete_all
    @default_product_options = {
      :quantity => 7, :name => 'test', :sku => 'test', :price => 7.50,
      :effective_on => (Date.today - 3), :quantity_committed => 0
    }
  end

  specify "should set a slug based on the name if not explicitly set" do
    @default_product_options.delete(:slug)
    p = Product.create!(@default_product_options)
    assert p.slug
    assert !p.slug.empty?
  end

  specify "should use an explicitly given slug unless it is the empty string" do
    @default_product_options[:slug] = "asdf"
    p = Product.create!(@default_product_options)
    assert p.slug
    assert_equal "asdf", p.slug
    p.destroy

    @default_product_options[:slug] = ""
    p = Product.create!(@default_product_options)
    assert p.slug
    assert !p.slug.empty?
  end

  specify "should have a quantity committed of zero" do
    p = Product.create!(@default_product_options)
    assert_equal 0, p.quantity_committed
    p.destroy

    @default_product_options.delete(:quantity_committed)
    p = Product.create!(@default_product_options)
    assert_equal 0, p.quantity_committed
  end

  specify "should not be available by default" do
    @default_product_options.delete(:effective_on)
    p = Product.create!(@default_product_options)
    assert !p.available?
  end
end

context "The Product class" do
  setup do
    CartLib.activate_test_stubs

    @ts1 = TagSet.create!(:name => 'Test Set One', :slug => '1')
    @ts2 = TagSet.create!(:name => 'Test Set Two', :slug => '2')
    @tag1 = Tag.create!(:name => 'one', :tag_set => @ts1)
    @tag2 = Tag.create!(:name => 'two', :tag_set => @ts2)
    @p1 = Product.create!(
            :name => '1', :sku => '1', :price => 1, :quantity  => 1,
            :effective_on => Date.today - 3
          )
    @p2 = Product.create!(
            :name => '2', :sku => '2', :price => 1, :quantity => 2,
            :effective_on => Date.today - 3
          )
    @p3 = Product.create!(
            :name => '3', :sku => '3', :price => 1, :quantity => 3,
            :effective_on => Date.today - 3
          )

    @p1.tag_activations.create(:tag => @tag1)

    @p2.tag_activations.create(:tag => @tag2)

    @p3.tag_activations.create(:tag => @tag1)
    @p3.tag_activations.create(:tag => @tag2)
  end

  specify "should find ids of all products with all of given a list of tags" do
    rv = Product.find_ids_by_tags(@tag1)
    assert_equal 2, rv.length
    assert [@p1.id.to_s, @p3.id.to_s].all?{|x| rv.include?(x)}
  end

  specify "should not find any products with only part of the specified list of tags" do
    rv = Product.find_ids_by_tags(@tag1, @tag2)
    assert_equal 1, rv.length
    assert_equal @p3.id.to_s, rv.first
  end

  specify 'should not find unavailable products when given a set of tags' do
    assert Product.find_ids_by_tags(@tag2).include?(@p2.id.to_s)
    @p2.update_attribute(:ineffective_on, Date.today-1)
    assert !@p2.available?
    assert !Product.find_ids_by_tags(@tag2).include?(@p2.id.to_s)
  end
  
  specify 'should return all tags' do
    assert_equal @p2.tags_by_set, {@ts2 => [@tag2]}
  end
end

context "Any product" do
  setup do
    CartLib.activate_test_stubs

    @p1 = Product.create!(
            :name => '1', :sku => '1', :price => 1, :quantity => 3,
            :effective_on => Date.today - 3, :ineffective_on => nil
          )
  end

  specify "should be available if first available date is in past and no discontinued date is set" do
    assert @p1.available?
  end
  
  specify "should toggle availability" do
    @p1.toggle_available!
    assert !@p1.available?
    @p1.toggle_available!
    assert @p1.available?
  end
  
  specify "should be available if the first available date is in past and discontinued date is in future" do
    @p1.update_attribute :ineffective_on, Date.today + 3
    @p1.reload
    assert @p1.available?
  end

  specify "should be available if first available date is today and no discontinued date is set" do
    @p1.update_attribute :effective_on, Date.today
    @p1.reload
    assert @p1.available?
  end

  specify "should be available if the first available date is today and discontinued date is in future" do
    @p1.update_attribute :effective_on, Date.today
    @p1.update_attribute :ineffective_on, Date.today + 3
    @p1.reload
    assert @p1.available?
  end

  specify "should not be available if first available date is not set" do
    @p1.update_attribute :effective_on, nil
    @p1.reload
    assert !@p1.available?
  end

  specify "should not be available if discontinued date is in past" do
    @p1.update_attribute :ineffective_on, Date.today - 1
    @p1.reload
    assert !@p1.available?
  end

  specify "should not be available if discontinued date is today" do
    @p1.update_attribute :ineffective_on, Date.today
    @p1.reload
    assert !@p1.available?
  end

  specify "should cache nothing if no thumbnails" do
    @p1.cache_images!
    assert !@p1.default_thumbnail_id
  end
  
  specify "should cache thumbnail" do
    #@p1.thumbnails = ProductImage.new(:image_path => "howdy.jpg")
    #@p1.cache_images!
    #assert_equal @p1.default_thumbnail_id, @p1.thumbnails
  end
end
