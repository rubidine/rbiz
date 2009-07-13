require 'rake/testtask'

begin
  require 'rcov/rcovtask'
rescue LoadError
  # NO RCOV
end

namespace :rbiz do

  desc "Run migrations for the RBiz extension"
  task :migrate => :environment do
    ActiveRecord::Base.establish_connection
    require File.join(File.dirname(__FILE__), '..', 'db', 'rbiz_migrator')
    RbizMigrator.migrate(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'), ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  desc 'Test the RBiz extension.'
  Rake::TestTask.new(:test) do |t|
    if defined?(RADIANT_ROOT)
      t.ruby_opts << "-r#{File.join(RADIANT_ROOT, 'test', 'test_helper')}"
    else
      t.ruby_opts << "-r#{File.join(RAILS_ROOT, 'test', 'test_helper')}"
    end
    t.ruby_opts << "-r#{File.join(File.dirname(__FILE__), '..', 'test', 'rbiz_test_helper')}"
    t.libs << File.join(File.dirname(__FILE__), '..', 'lib')
    t.pattern = File.join(File.dirname(__FILE__), '..', 'test/**/*_test.rb')
    t.verbose = true
  end

  if defined?(Rcov)
    require 'rbconfig'
    desc 'Generate code coverage reports.'
    Rcov::RcovTask.new do |t|
      #t.libs << File.join(File.dirname(__FILE__), '..', 'test')
      t.pattern = File.join(File.dirname(__FILE__), '..', 'test', 'rcov.rb')
      t.verbose = true

#=begin
      myname = File.dirname(__FILE__).split('/')[-2]
      op = Dir[File.dirname(__FILE__) + "/../../*"].map{|x| File.basename(x)}
      op.reject!{|x| x == myname}
      op = op.collect{|x| "vendor/plugins/#{x}"}
      op = op.join(',')
      xo = "--exclude-only #{Config::CONFIG['prefix']},config,environment,vendor/rails,#{op},ext_lib,test"
      t.rcov_opts = [xo]
#=end

    end
  end

end
