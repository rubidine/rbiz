context 'A CartConfig' do
  setup do
    CartConfig.delete_all
    CartConfig.set :test, 'this key/scope exists', :test
  end

  specify 'is invalid if [name,scope] tuple is not unique' do
    c = CartConfig.new :name => 'test', :scope => 'test', :value => 'overwriting'
    assert !c.valid?
  end

  specify 'will have a record if false value' do
    CartConfig.set :test, false, :another
    assert CartConfig.find_by_scope_and_name('another', 'test')
  end

  specify 'will not have a record with nil value' do
    CartConfig.set :test, nil, :another
    assert !CartConfig.find_by_scope_and_name(:another, :test)
  end

  specify 'can have a hash for a value' do
    CartConfig.set :test, {:your => 'mother'}, :another
    assert_kind_of Hash, CartConfig.get(:test, :another)
  end

  specify 'does not need scope' do
    CartConfig.set :test, {:your => 'mother'}
    assert_kind_of Hash, CartConfig.get(:test)
  end

  specify 'finds name in correct scope' do
    CartConfig.set :test, 'another scope', :another
    assert_equal 'this key/scope exists', CartConfig.get(:test, :test)
  end

  specify 'returns nil for not-found records' do
    assert_nil CartConfig.get(:your, :mother)
  end

  specify 'deletes a record if set with nil value' do
    assert CartConfig.find_by_scope_and_name('test', 'test')
    CartConfig.set(:test, nil, :test)
    assert !CartConfig.find_by_scope_and_name('test', 'test')
  end

  specify 'cannot be destroyed by ordinary means (nor by a wish spell)' do
    rec = CartConfig.find :first
    assert_raise NoMethodError do
      rec.destroy
    end
    assert_raise NoMethodError do
      rec.destroy!
    end
  end

  specify 'cannot be created directly' do
    assert_raise NoMethodError do
      CartConfig.create(:name => 1, :value => 2, :scope => 3)
    end
    assert_raise NoMethodError do
      CartConfig.create!(:name => 1, :value => 2, :scope => 3)
    end
  end

  specify 'cannot be (new => save)d directly' do
    cc = CartConfig.new(:name => 1, :value => 2, :scope => 3)
    assert_raise NoMethodError do
      cc.save
    end
    assert_raise NoMethodError do
      cc.save!
    end
  end

  specify 'cannot be (find => save)d directly' do
    cc = CartConfig.find :first
    assert_raise NoMethodError do
      cc.save
    end
    assert_raise NoMethodError do
      cc.save!
    end
  end

  specify 'will overwrite old values of same key/scope' do
    CartConfig.set :test, 'new value', :test
    assert_equal 'new value', CartConfig.get(:test, :test)
  end

  specify 'can dump/load to/from YAML' do
    CartConfig.delete_all
    c = CartConfig.set(:name, {"value" => "VVAL"}, :scope)
    y = CartConfig.dump
    CartConfig.delete_all
    CartConfig.load y
    assert CartConfig.get(:name, :scope)
    assert_kind_of Hash, CartConfig.get(:name, :scope)
  end

end

context 'A Cart Config with a basic type of "Boolean"' do
  setup do
    CartConfig.delete_all
    cc = CartConfig.new(
      :name => 'test',
      :scope => 'test',
      :basic_type => 'Boolean'
    )
    cc.value = true
    cc.send :save!
  end

  specify 'should return a bool if basic type is "Boolean"' do
    assert_kind_of TrueClass, CartConfig.get(:test, :test)
  end

  specify 'should set "1" to true' do
    CartConfig.set :test, '1', :test
    assert_kind_of TrueClass, CartConfig.get(:test, :test)
  end

  specify 'should set "0" to false' do
    CartConfig.set :test, '0', :test
    assert_kind_of FalseClass, CartConfig.get(:test, :test)
  end

  specify 'should remove record when set to nil' do
    CartConfig.set :test, nil, :test
    assert_kind_of NilClass, CartConfig.get(:test, :test)
  end
end

context 'A Cart Config with a basic type of "String"' do
  setup do
    CartConfig.delete_all
    cc = CartConfig.new(
      :name => 'test',
      :scope => 'test',
      :basic_type => 'String'
    )
    cc.value = 'my value'
    cc.send :save!
  end

  specify 'should return a string if value given' do
    assert_kind_of String, CartConfig.get(:test, :test)
  end

  specify 'should write empty string' do
    CartConfig.set :test, '', :test
    cc = CartConfig.find_by_name_and_scope 'test', 'test'
    assert cc
  end

  specify 'should return nil if string is empty' do
    CartConfig.set(:test, '', :test)
    assert_nil CartConfig.get(:test, :test)
  end

  specify 'should not delete if value is empty' do
    assert CartConfig.find_by_name_and_scope('test', 'test')
    CartConfig.set(:test, '', :test)
    assert CartConfig.find_by_name_and_scope('test', 'test')
  end
end
