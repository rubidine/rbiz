# A Tag is a navigation tool.  Some tags are shown for the main navigation.
# Some are show to allow better filtering.  Its all about browsing.
class Tag < ActiveRecord::Base
  validates_presence_of :tag_set_id, :slug, :name
  validates_uniqueness_of :slug
  validates_uniqueness_of_tuple :name, :tag_set_id

  belongs_to :tag_set, :counter_cache => true
  has_many :tag_activations, :dependent => :destroy
  has_many :products, :through => :tag_activations

  acts_as_list :scope => :tag_set

  before_validation :default_slug
  def slug= new_slug
    return if new_slug.nil? or new_slug.empty?
    write_attribute(:slug, new_slug)
  end

  #
  # Given an array of slugs, map it to tags, ignoring any that don't map
  #
  def self.for_slugs *slug_list
    # if we get in an array, or if we get in a list of slugs, treat it the same
    slug_list = [slug_list].flatten

    # map to tags, remove any not found
    slug_list.collect{|x| find_by_slug(x)}.compact
  end


  #
  # Given a list of Strings (tag names) or Tag objects, return
  # all other tags that apply to any products as along with all of those tags.
  # Returns a hash of {TagSet => [Tag]}
  #
  def self.related_for *names_or_tags
    names_or_tags.flatten!

    # Turn tag names into real tags
    tags = names_or_tags.collect do |t|
      t.is_a?(String) ? Tag.find_by_slug(t, :include=>:products) : t
    end
    tags.compact!

    product_ids = Product.find_ids_by_tags(tags)
    return {} if product_ids.empty?

    # Ids for tags passed in and  all products with all tags applied to them
    tag_ids = '(' + tags.collect{|x| x.id}.join(',') + ')'
    product_ids = '(' + product_ids.join(',') + ')'

    # return a hash TagSet => [Tag, Tag]
    tags_by_set = {}

    # for each product with all the tags, what other tags do they have
    cond = "products.id IN #{product_ids}"
    (cond << " AND tags.id NOT IN #{tag_ids}") unless tags.empty?
    find(
      :all,
      :include => [:products, :tag_set],
      :conditions => cond
    ).each do |tg|
      (tags_by_set[tg.tag_set] ||= []) << tg
    end

    tags_by_set
  end

  private
  def default_slug
    self.slug ||= name.to_s.gsub(/[^(\w|\d|\-|_)]/, '-').downcase
  end

end
