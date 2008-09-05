module OfficeHelper

  include OfficeViewExtender

  def tag_select exclude_product=nil
    rv = Tag.find(:all, :include=>[:tag_set])
    rv.reject!{|x| exclude_product.tags.include?(x)} if exclude_product
    rv.collect{|x| ["#{x.tag_set.name}: #{x.name}", x.id]}
  end

  def option_set_select exclude_if_on_product=nil
    rv = OptionSet.find(:all)
    if exclude_if_on_product
      rv.reject!{|x| exclude_if_on_product.option_sets.include?(x)}
    end
    rv.collect{|x| [x.name, x.id]}
  end

  def option_select for_set
    for_set.options.collect{|x| [x.name, x.id]}
  end

  def tag_set_select
    TagSet.find(:all).collect{|x| [x.name, x.id]}
  end

  def error_block name
    rv = <<-EOF
    <div id="#{name}_error_container" style="display: none">
      #{link_to_function(
        image_tag('cart/rollup.png', :alt => 'Hide Message')
      ) do |page|
        page["#{name}_error_container"].hide
      end}
      <div id="#{name}_error"></div>
    </div>
    EOF
  end
end
