context 'A new customer' do
  setup do
    Customer.delete_all

    CartLib.activate_test_stubs

    @customer = Customer.new(
                  :email => 'testie@localhost',
                  :passphrase => 'testie00'
                )
  end

  specify 'should have a hashed passphrase' do
    assert_not_equal 'testie00', @customer.passphrase
    assert @customer.passphrase_eql?('testie00')
  end
end

context 'The Customer class' do
  setup do
    Customer.delete_all
    CartLib.activate_test_stubs
  end

  specify 'should generate random passphrases' do
    all = []
    90.times do
      all << Customer.generate_random_passphrase
      assert_match /^[a-zA-Z0-9_\-]{10,15}$/, all.last
    end
    # doesn't have to be true, but in reality is likely to
    assert_equal 90, all.uniq.length, "Non unique passphrases (not fatal)"
  end

  specify 'should not let the super_user attribute be set on creation' do
    c = Customer.new(:super_user => true)
    assert !c.super_user?
    c.super_user = true
    assert c.super_user?
  end
end
