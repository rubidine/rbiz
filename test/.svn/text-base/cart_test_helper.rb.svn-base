require 'test/spec'
require 'mocha'

module FixtureReplacement
  @defaults_file = File.join(File.dirname(__FILE__), 'example_data.rb')
end
require 'fixture_replacement'

Test::Unit::TestCase.send :include, FixtureReplacement
CartLib.activate_test_stubs

