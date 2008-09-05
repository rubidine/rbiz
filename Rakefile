require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :test

def find_config_file
  fn = File.dirname(__FILE__)
  while File.expand_path(fn) != '/'
    check = File.join(fn, 'config', 'environment.rb')
    return check if File.exist?(check)
    fn = File.join(fn, '..')
  end
end

desc 'Test the cart plugin.'
Rake::TestTask.new(:test) do |t|
  conf = find_config_file
  require conf

  if defined?(RADIANT_ROOT)
    t.ruby_opts << "-r#{File.join(RADIANT_ROOT, 'test', 'test_helper')}"
  else
    t.ruby_opts << "-r#{File.join(RAILS_ROOT, 'test', 'test_helper')}"
  end
  t.ruby_opts << "-r#{File.join(File.dirname(__FILE__), 'test', 'cart_test_helper')}"
  t.libs << File.join(File.dirname(__FILE__), 'lib')
  t.pattern = File.join(File.dirname(__FILE__), 'test/**/*_test.rb')
  t.verbose = true
end

desc 'Generate documentation for the cart plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cart'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end
