Factory.define :customer do |c|
  c.email 'testie@localhost'
  c.passphrase 'testie00'
end

Factory.define :cart do |c|
  c.association :customer
end

Factory.define :product do |p|
  p.name 'test'
  p.sku 'test'
  p.price 1.50
  p.effective_on Date.today - 3
  p.quantity 10
end

Factory.define :unlimited_product, :parent => :product do |p|
  p.sequence(:name){|n| "product#{n}"}
  p.sequence(:sku){|n| "sku#{n}"}
  p.unlimited_quantity true
end

Factory.define :scoped_product, :parent => :product do |p|
  p.name 'test2'
  p.sku 'test2'
  p.price 7.50
  p.quantity 5
end

Factory.define :expired_product, :parent => :product do |p|
  p.sequence(:name){|n| "extended_product#{n}"}
  p.sequence(:sku){|n| "extsku#{n}"}
  p.effective_on Date.today - 7
  p.ineffective_on Date.today - 3
end

Factory.define :pending_product, :parent => :product do |p|
  p.sequence(:name){|n| "pending#{n}"}
  p.sequence(:sku){|n| "pendsku#{n}"}
  p.effective_on Date.today + 2
end

Factory.define :option_set do |o|
  o.name 'test set'
end

Factory.define :option do |o|
  o.name 'test_option'
end

Factory.define :variation do |o|
  o.quantity 7
  o.quantity_committed 0
end

Factory.define :option_specification do |a|
end

Factory.define :coupon do |a|
end

Factory.define :cart do |a|
end

Factory.define :error_message do |a|
end

Factory.define :tag do |a|
end

Factory.define :gateway_response do |a|
end


Factory.define :line_item do |a|
end
