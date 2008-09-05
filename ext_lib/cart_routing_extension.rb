module CartRoutingExtension

  def draw_with_cart
    draw_without_cart do |map|
      if @cart_route_block
        @cart_route_block.call(map)
      end
      yield map
    end
  end

  def define_cart_routes &blk
    @cart_route_block = blk
  end

  public
  def self.included(base)
    base.send :alias_method_chain, :draw, :cart
  end

end
