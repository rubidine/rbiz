require 'singleton'
module OfficeViewExtender

  def self.register key, *render_args, &blk
    (Registry.instance[key] ||= []) << (blk || render_args)
  end

  def self.unregister key, *render_args, &blk
    return unless Registry.instance[key]
    Registry.instance[key].delete(blk || render_args)
  end

  def extension_point key
    if Registry.instance[key]
      Registry.instance[key].collect do |render_args|
        if render_args.is_a?(Proc)
          render(render_args.call)
        elsif render_args.length == 1 and render_args.first.is_a?(String)
          render_args.first
        else
          render *render_args
        end
      end.join("\n")
    end
  end

  class Registry < Hash
    include Singleton
  end
end
