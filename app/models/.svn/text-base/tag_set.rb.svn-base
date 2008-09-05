# A tag set contains multiple tags that have a similar role in navigation.
# We can have a TagSet of 'Department' and Tags of 'Housewares', 'Automotive',
# &c.  Typically (but not always), a product will not have more than one Tag
# in any TagSet.  TagSet is also called a Category in many places in the app.
class TagSet < ActiveRecord::Base
  validates_uniqueness_of :name, :slug
  validates_presence_of :name, :slug

  has_many :tag_activations
  has_many :products, :through => :tag_activations
  has_many :tags, :order => 'position', :dependent => :destroy

  before_validation :default_slug

  def slug= new_slug
    return if new_slug.nil? or new_slug.empty?
    write_attribute(:slug, new_slug)
  end

  private
  def default_slug
    self.slug ||= name.downcase.gsub(/[^\w\s\d\-_]/, '').gsub(/\s+/, '_')
  end
end
