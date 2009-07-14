context 'a new tag set' do
  setup do
    CartLib.activate_test_stubs

    TagSet.delete_all

    @ts = TagSet.create! :name => 'test'
  end

  specify 'will automatically set the slug' do
    assert_kind_of String, @ts.slug
  end

  specify 'will not set a empty slug' do
    @ts.slug = nil
    assert !(@ts.slug.nil? || @ts.slug.empty?)
    @ts.slug = ''
    assert !(@ts.slug.nil? || @ts.slug.empty?)
  end
end
