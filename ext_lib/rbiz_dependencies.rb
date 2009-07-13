module RbizDependencies

  def self.load &blk
    return unless blk
    ActionController::Dispatcher.to_prepare :rbiz, &blk
  end

  def self.unload &blk
    return unless blk
    ActionController::Dispatcher.class_eval do
      # This is what to_prepare does, but for the after_dispatch callback
      @after_dispatch_callbacks ||= ActiveSupport::Callbacks::CallbackChain.new
      callback = ActiveSupport::Callbacks::Callback.new(
                   :after_dispatch,
                   blk,
                   :identifier => :rbiz
                 )
      @after_dispatch_callbacks.replace_or_append!(callback)
    end
  end
end
