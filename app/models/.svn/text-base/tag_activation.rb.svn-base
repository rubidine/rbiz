# A decorated join model for Product and Tag
class TagActivation < ActiveRecord::Base
  set_table_name 'products_tags'

  belongs_to :product
  belongs_to :tag
  belongs_to :tag_set

  validates_presence_of :product, :tag, :tag_set

  def tag_with_denormalize_tag_set= tg
    self.tag_without_denormalize_tag_set= tg
    self.tag_set= tg.tag_set
  end
  alias_method_chain :tag=, :denormalize_tag_set
end
