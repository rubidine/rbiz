# Products have a sorted list of images that have thumbnails
class ProductImage < ActiveRecord::Base
  acts_as_list :scope=>'product_id = #{product_id} and thumbnail = 1'
  validates_uniqueness_of :image_path
  belongs_to :product
  belongs_to :twin, :class_name => "ProductImage", :foreign_key => :twin_id

  include ProductImageHandler

  before_validation :process_pending_file_data
  before_validation :thumbnail_is_null_if_false
  after_save :relink_twin
  after_save :update_default_product_image_if_top_thumbnail

  # filedata is a file_field that will be processed by ProductImageHandler
  # in the before_validation callback process_pending_file_data
  def filedata= fd
    fd.rewind
    @pending_file_data = fd.read
    @original_name = fd.original_filename
  end

  private
  def process_pending_file_data
    return unless @pending_file_data
    path = fullsize_path(@original_name)
    self.image_path = path.gsub(/^#{RAILS_ROOT}\/public/, '')
    write_file(fullsize(@pending_file_data), path)
    create_thumbnail(@pending_file_data, @original_name)
  end

  def create_thumbnail fd, oname
    twin = ProductImage.new(self.attributes)
    twin.thumbnail = true
    path = thumbnail_path(oname)
    twin.image_path = path.gsub(/^#{RAILS_ROOT}\/public/, '')
    write_file(thumbnail(fd), path)
    if twin.save
      self.twin = twin
    end
  end

  def relink_twin
    if twin and !twin.twin
      twin.twin = self
      twin.save
    end
  end

  # Because some databases it is 'f' and others it is '0'
  # and we need a specific target for acts_as_list scope
  def thumbnail_is_null_if_false
    self.thumbnail = nil unless self.thumbnail?
  end

  def update_default_product_image_if_top_thumbnail
    if thumbnail? and position == 1
      product.default_thumbnail = self
      product.default_image = twin
      product.save
    end
  end
end
