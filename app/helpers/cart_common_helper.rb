module CartCommonHelper
  def tag_link(t, *others)
    others.flatten!
    all = others + [t]
    all.compact!
    all.sort!{|a,b| (a.is_a?(String) ? a : a.slug) <=> (b.is_a?(String) ? b : b.slug)}
    link = all.collect{|x| x.is_a?(String) ? x : x.slug}.join('/')

    link_to( t ? t.name : image_tag('x.png', :alt=>"remove from filter"), "/browse/#{link}")
  end

  def product_thumbnail product
    i = product.default_thumbnail
    if i.nil?
      i = product.thumbnails.first
    end
    if i
      image_tag(i.image_path, :alt=>i.image_alt)
    else
      image_tag(CartConfig.get(:missing_thumbnail, :image), :alt=>CartConfig.get(:missing_thumbnail_alt, :image))
    end
  end

  def product_link product, opts={}
    opts[:title] ||= "View details for #{product.name}"
    link_to opts[:title].to_s, "/cart/product/#{product.slug}"
  end
end
