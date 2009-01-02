#
# This is where money is made.  Be sure to sell it for more than you paid.
#
class Product < ActiveRecord::Base

  #
  # VALIDATIONS
  #

  validates_uniqueness_of :slug, :allow_nil => true
  validates_uniqueness_of :sku
  validates_presence_of :sku, :name, :price
  validates_numericality_of :weight, :allow_nil=>true
  validates_numericality_of :price, :shipping, :allow_nil=>true
  validate :non_negative_quantity

  #
  # ASSOCIATIONS
  #

  has_many :product_images
  has_many :thumbnails,
           :class_name=>'ProductImage',
           :conditions=>'thumbnail IS NOT NULL',
           :order=>'position'
  has_many :images,
           :class_name=>'ProductImage',
           :conditions=>'thumbnail IS NULL',
           :order=>'position'
  belongs_to :default_thumbnail,
             :class_name=>'ProductImage',
             :foreign_key=>'default_thumbnail_id'
  belongs_to :default_image,
             :class_name=>'ProductImage',
             :foreign_key=>'default_image_id'
  has_many :tag_activations, :include => [:tag, :tag_set]
  has_many :tags, :through => :tag_activations
  has_many :tag_sets, :through => :tag_activations
  has_many :option_sets
  has_many :variations, :dependent=>:destroy
  has_many :quantity_reservations, :as => :reserved_object, :dependent => :destroy

  #
  # ACCESSORS
  #

  fixed_point_field :price
  fixed_point_field :shipping
  fixed_point_field :msrp

  # Override quantity, expiration date, and effective date on creation
  attr_writer :noexpire, :inactive

  #
  # CALLBACKS
  #

  before_validation :default_slug
  before_validation :clean_slug
  before_validation :override_effective_on_with_dont_make_available
  before_validation :override_ineffective_on_with_always_available
  before_save :dont_write_cache_commitment
  after_save :load_cached_commitment

  #
  # NAMED SCOPES
  #

  named_scope :featured, {:conditions => {:featured => true}}
  named_scope :available, {
    :conditions => [
      'effective_on <= ? AND (ineffective_on >= ? OR ineffective_on IS NULL) AND
      unlimited_quantity = TRUE OR quantity > 0',
      Date.today, Date.today
    ]
  }

  #
  # Collect all Tags on the product in a Hash, keyed by TagSet
  #
  def tags_by_set
    rv = {}
    tags.find(:all).each do |t|
      rv[t.tag_set] ||= []
      rv[t.tag_set] << t
    end
    rv
  end

  #
  # Can be sold today?
  # (only checks availablity dates, not quantity)
  #
  def available?
    effective_on and \
    effective_on <= Date.today and \
    (ineffective_on.nil? or ineffective_on > Date.today)
  end

  #
  # If it was available, take it off market
  # If it was not, make it available
  def toggle_available!
    if available?
      update_attribute(:ineffective_on, Date.today)
    else
      update_attributes( :ineffective_on => nil, :effective_on => Date.today )
    end
  end

  #
  # If images are reordered, you want to call this, since we store a pointer
  # to the first image in the Product model so it can easily be loaded
  # with an :include .
  #
  def cache_images!
    if thumbnails.empty?
      update_attribute(:default_thumbnail_id, nil)
      update_attribute(:default_image_id, nil)
    else
      update_attribute(:default_thumbnail_id, thumbnails.first.id)
      update_attribute(:default_image_id, thumbnails.first.twin.id)
    end
  end

  #
  # given a list of tags and the page, generate a pagination
  #
  def self.paginate_for_tags tags, page_number=nil
    # if page_number comes from params, could be explicit nil, so default != 1

    ids = find_ids_by_tags(tags)
    if ids.empty?
      empty_pagination
    else
      paginate(
        :conditions => {:id => ids},
        :page => (page_number || 1), 
        :per_page => CartConfig.get(:products_per_page, :store)
      )
    end

    # return from condition above
  end

  #
  # Hide some ugly SQL for browsing the site by tags
  #
  def self.find_ids_by_tags *tags
    tags.flatten!
    tag_ids = tags.collect{|x| x.id}
    if tag_ids.length > 0
      joins = ""
      where = ""
      tag_ids.each_with_index do |x,index|
        if index != 0
          joins << " JOIN products_tags pt#{index}"
          joins << " ON pt0.product_id=pt#{index}.product_id "
        end
        where << (!where.empty? ? ' AND ' : '')
        where << " pt#{index}.tag_id = #{x.to_i} "
      end
      rv = find_by_sql [
        "SELECT DISTINCT pt0.product_id FROM products_tags pt0 #{joins}
        JOIN products p0 ON p0.id = pt0.product_id
        WHERE #{where} AND p0.effective_on <= ?
        AND (p0.ineffective_on IS NULL or p0.ineffective_on > ?)
        AND (unlimited_quantity = 1 OR quantity > 0)",
        Date.today, Date.today
      ]
    else
      rv = find_by_sql "SELECT DISTINCT product_id FROM products_tags"
    end
    rv.collect{|x| x.product_id}
  end

  # Return a two-dimensional array of [OptionSet.name, OptionSet.id]
  # for each option set that belongs to this product, for use in a select tag.
  def option_sets_for_select
    option_sets.collect{|x| [x.name, x.id]}
  end

  # The option matrix of a Product is a two-dimensional array that is a listing
  # of every possible distinct tuple of Option elements that can be applied
  # to the current product.  This does not look at inventory or if a
  # Variation exists for the set of options.
  #
  # Example:
  #   Given option sets "OS1" and "OS2"
  #   "OS1" having options "OPT1-1", "OPT1-2"
  #   "OS2" having options "OPT2-3", "OPT2-4"
  #
  #   Returns
  #   [
  #     [OPT1-1, OPT2-3],
  #     [OPT1-1, OPT2-4],
  #     [OPT1-2, OPT2-3],
  #     [OPT1-2, OPT2-4]
  #   ]

  def option_matrix exclude_set = nil 
    return [] if option_sets.empty?
    my_option_sets = option_sets.dup
    if exclude_set  
      my_option_sets.delete(exclude_set) 
    end

    rv = []

    desired_columns = [
      :name, :price_adjustment, :has_input, :sku_extension, :weight_adjustment, 
      :short_description, :id,
    ]

    query_tables = []
    my_option_sets.sort{|a,b| a.name <=> b.name}.each_with_index do |set, idx|
      query_tables << ["os#{idx}", set]
    end

    selections = []
    conditions = []
    joins = []
    order = []

    query_tables.each do |tbl, set|
      selections << desired_columns.collect{|col| "#{tbl}.#{col} as #{tbl}_#{col}"}.join(",")
      conditions << "#{tbl}.option_set_id = #{set.id.to_i}"
      joins << "options as #{tbl}"
      order << "#{tbl}.name"
    end

    query = 'SELECT '
    query << selections.join(',')
    query << ' FROM '
    query << joins.join(' JOIN ')
    query << ' WHERE '
    query << conditions.join(' AND ')
    query << ' ORDER BY '
    query << order.join(',')

    mega_options = Option.find_by_sql(query)
    mega_options.each do |megaopt|
      rv << query_tables.collect do |tbl, set| 
              attrib = {}
              desired_columns.each do |col|
                attrib[col] = megaopt["#{tbl}_#{col}"]
              end
              o = Option.new(attrib)
              o.option_set = set
              o.id = attrib[:id]
              o.readonly!
              o
            end

    end

    return rv
  end

  # {
  #   BLUE:
  #   {
  #     children =>
  #     {
  #       PLAID: { ... },
  #       STRIPED: { ... },
  #       DOTTED: { ... }
  #     },
  #     x_has_user_input => true | false,
  #     price_adjustment => amount,
  #     sku_extension => sku | null
  #   }
  #   RED:
  #   {
  #     children =>
  #     {
  #       PLAID: { ... },
  #       STRIPED: { ... }
  #     },
  #     x_has_user_input => true | false,
  #     price_adjustment => amount,
  #     sku_extension => sku | null,
  #     option_id => 37
  #   }
  # }
  #
  # Used for selecting one option, and finding what else is available
  # from there.  JSON version useful for selection javascript (but can be
  # large).  Options are nested in order of OptionSet.name.
  def available_option_nesting

    option_set_names = {}
    option_sets.each{|x| option_set_names[x.id] = x.name}

    rv = {}
    variations.find(:all, :include=>['options']).each do |pos|
      # record previous options to know how to traverse rv
      popts = []

      # sort this sets options by their option set name
      sort_opt = pos.options.sort do |x,y|
        option_set_names[x.option_set_id] <=> option_set_names[y.option_set_id]
      end

      # for each of the sorted options
      sort_opt.each_with_index do |o,idx|

        # take the rv hash
        # {
        #   prevoption1:
        #   {
        #     children =>
        #     {
        #       prevoption2: {} <-- this is curhash
        #     },
        #     x_has_user_input => true | false,
        #     price_adjustment => amount,
        #     sku_extension => sku | null
        #   }
        # }
        # and find our position in it
        # as we add into curhash we also add into rv, its a pointer inside
        curhash = popts.inject(rv) do |main_hash, key|
          rhash = main_hash[key.name]
          if rhash
            rhash = rhash['children']
          else
            raise "Unable to build option set " + \
                  pos.options.collect{|x| "#{x.option_set.name} #{x.name}"} \
                  .join(', ')  + \
                  " | rv: #{rv.inspect} pots: #{popts.inspect}"
          end
          rhash
        end

        # if there are no more options, just append the variation id
        curhash[o.name] ||= {}
        curhash[o.name]['children'] ||= (((idx + 1) == sort_opt.length) ? \
                                          pos.id : \
                                          {}
                                        )
        curhash[o.name]['x_has_user_input'] = o.has_input?
        curhash[o.name]['option_id'] = o.id
        curhash[o.name]['price_adjustment'] = o.price_adjustment
        curhash[o.name]['sku_extension'] = o.sku_extension

        # put this option on the list of those we already computed
        popts << o
      end
    end

    rv

  end

  # for check box on form
  def noexpire
    ineffective_on.nil?
  end

  # for check box on form
  def inactive
    effective_on.nil?
  end

  def variations_for_option_ids option_ids
    if option_ids.length > 0
      joins = ""
      where = ""
      option_ids.each_with_index do |x,index|
        if index != 0
          joins << " JOIN products_tags pt#{index}"
          joins << " ON pt0.product_id=pt#{index}.product_id "
        end
        where << (!where.empty? ? ' AND ' : '')
        where << " pt#{index}.tag_id = #{x.to_i} "
      end
      rv = find_by_sql [
        "SELECT DISTINCT pt0.product_id FROM products_tags pt0 #{joins}
        JOIN products p0 ON p0.id = pt0.product_id
        WHERE #{where} AND p0.effective_on <= ?
        AND (p0.ineffective_on IS NULL or p0.ineffective_on > ?)",
        Date.today, Date.today
      ]
    else
      rv = find_by_sql "SELECT DISTINCT product_id FROM products_tags"
    end
    rv.collect{|x| x.product_id}
  end

  def has_options?
    option_sets.count != 0
  end

  private

  def override_effective_on_with_dont_make_available
    if @inactive and @inactive.to_i == 1
      self.effective_on = nil
    end
  end

  def override_ineffective_on_with_always_available
    if @noexpire and @noexpire.to_i == 1
      self.ineffective_on = nil
    end
  end

  def default_slug
    if slug.nil? or slug.to_s.empty?
      self.slug = name
    end
  end

  def clean_slug
    if slug
      self.slug = slug.to_s.gsub(/[^\w\d\-]/, '_').downcase
    end
  end

  def non_negative_quantity
    if quantity.to_i < 0
      errors.add(:quantity, 'should not be negative')
    end
  end

  #
  # The 'quantity_committed' column should only be changed by the counter cache
  #
  def dont_write_cache_commitment
    if changes['quantity_committed']
      self.quantity_committed = changes['quantity_committed'][0]
    end
  end

  def load_cached_commitment
    self.quantity_committed = quantity_reservations.count
  end

  def self.empty_pagination
    WillPaginate::Collection.new(
      1,                                              # current page
      CartConfig.get(:products_per_page, :store),     # per page
      0                                               # total pages
    )
  end
end
