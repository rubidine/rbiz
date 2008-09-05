module FixtureReplacement

  attributes_for :customer do |c|
    c.email = 'testie@localhost'
    c.passphrase = 'testie00'
	end

  attributes_for :cart do |c|
    c.associated_object = default_customer
  end

  attributes_for :product do |p|
    p.name = 'test'
    p.sku = 'test'
    p.price = 1.50
    p.quantity = 3
    p.effective_on = Date.today - 3
    p.quantity = 10
	end

  attributes_for :unlimited_product, :from => :product do |p|
    p.name = p.sku =  String.random
    p.unlimited_quantity = true
  end

  attributes_for :scoped_product, :from => :product do |p|
    p.name = 'test2'
    p.sku = 'test2'
    p.price = 7.50
    p.quantity = 5
	end

  attributes_for :expired_product, :from => :product do |p|
    p.name = String.random
    p.sku = String.random
    p.effective_on = Date.today - 7
    p.ineffective_on = Date.today - 3
  end

  attributes_for :pending_product, :from => :product do |p|
    p.name = String.random
    p.sku = String.random
    p.effective_on = Date.today + 2
  end

  attributes_for :option_set do |o|
    o.name = 'test set'
	end

  attributes_for :option do |o|
    o.name = 'test_option'
	end

  attributes_for :product_option_selection do |o|
    o.quantity = 7
    o.quantity_committed = 0
	end

  attributes_for :option_specification do |a|
    
	end

  attributes_for :coupon do |a|
    
	end

  attributes_for :cart do |a|
    
	end

  attributes_for :error_message do |a|
    
	end

  attributes_for :tag do |a|
    
	end

  attributes_for :gateway_response do |a|
    
	end


  attributes_for :line_item do |a|
    
	end

end
