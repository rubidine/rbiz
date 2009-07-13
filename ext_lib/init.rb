# load Dispatcher if not present yet
unless defined?(ActionController) and defined?(ActionController::Dispatcher)
  require 'action_controller/dispatcher'
end

require File.join(File.dirname(__FILE__), 'rbiz_dependencies')

vp = File.join(File.dirname(__FILE__), '..', 'app', 'views')
ActionController::Base.prepend_view_path(vp)

# copy in assets
require 'fileutils'
['javascripts', 'stylesheets', 'images'].each do |type|
  r_path = File.join(RAILS_ROOT, 'public', type, 'cart')
  p_path = File.join(File.dirname(__FILE__), '..', 'public', type, 'cart')
  unless File.directory?(r_path)
    FileUtils.mkdir_p(r_path)
  end
  Dir["#{p_path}/*"].each do |asset|
    unless File.exist?(File.join(r_path, File.basename(asset)))
      FileUtils.copy(asset, r_path)
    end
  end
end
