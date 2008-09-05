require File.dirname(__FILE__) + '/../../../../test/test_helper'

module FixtureReplacement
  @defaults_file = File.join(File.dirname(__FILE__), 'example_data.rb')
end
require 'fixture_replacement'
Test::Unit::TestCase.send :include, FixtureReplacement
CartLib.activate_test_stubs

Dir[File.dirname(__FILE__) + '/unit/*_test.rb'].each do |f|
  require f
end
