# CartConfig tracks configuration options, and has a terse syntax, so you
# dont ever have to <tt>find</tt> a record, you can just <tt>get</tt>
# the record for the given key.  It supports namespacing!  If a configuration
# option is not set, <tt>get</tt> returns <tt>nil</tt>.
#
# Example
# <tt>
# CartConfig.set(:app_name, 'My App')
# CartConfig.get(:app_name) => 'My App'
# CartConfig.set(:option_hash, {:key => 'value'}, :scope)
# CartConfig.get(:option_hash, :scope) => {:key =. 'value'}
# CartConfig.set(:app_name, nil) => deletes from database
# CartConfig.get(:app_name) => nil
# </tt>
class CartConfig < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of_tuple :name, :scope
  validate :not_nil_value

  # CartConfig.get('products_per_page', 'office')
  # CartConfig.get('products_per_page') // no scope
  # CartConfig.get('non_existant_key') => nil
  def self.get name, scope=nil
    conditions = scope ? \
      ['scope = ? and name = ?', scope.to_s, name.to_s] : \
      ['scope is null and name = ?', name.to_s]
    x = find(:first, :conditions=>conditions)
    return nil unless x
    x.value
  end

  # CartConfig.set('products_per_page', 80, 'office')
  # CartConfig.set('products_per_page', 80) // null scope
  # CartConfig.set('products_per_page', null, 'office') // delete
  # CartConfig.set('products_per_page', null) // delete // null scope
  def self.set name, value, scope=nil
    conditions = scope ? \
      ['scope = ? and name = ?', scope.to_s, name.to_s] : \
      ['scope is null and name = ?', name.to_s]
    x = find(:first, :conditions=>conditions)
    if x and value.nil?
      x.send :destroy
    elsif x
      x.value = value
      x.send :save
    elsif value.nil?
      # do nothing, it doesn't exist and we're trying to purge it
      nil
    else
      x= new :name=>name.to_s, :value=>value, :scope=>(scope ? scope.to_s : nil)
      unless x.send(:save)
        raise x.errors.full_messages.join("\n")
      end
      x.value
    end
  end

  def value
    rv = @attributes['value']
    rv = YAML.load(rv) if rv and serialize?
    convert_value(rv)
  end

  def value= newval
    write_attribute(:value, serialize(newval))
  end

  # Returns a string of YAML that represents all configuration options.
  # Can be loaded into another instance with <tt>CartConfig.load</tt>
  def self.dump
    self.find(:all).collect{|x| x.attributes.merge('value' => x.value)}.to_yaml
  end

  # Load YAML (usually from <tt>CartConfig.dump</tt>
  def self.load yml
    YAML.load(yml).each do |x|
      # We have to set basic type before value!
      val = x.delete('value')
      y = CartConfig.new x
      y.value = val
      y.send(:save)
    end
  end

  # move the namespace of these methods
  # so save, create, &c don't work as usual
  #
  # dont alias find or unique_tuple fails

  protected :save, :save!, :destroy
  class << self
    protected :create, :create!
  end

  private
  # Convert value based on basic type
  def convert_value(val)
    case basic_type
    when nil
      val
    when /^str/i
      (val.nil? or val.empty?) ? nil : val
    when /^bool/i
      if val.is_a?(TrueClass) or val.is_a?(FalseClass)
        val
      elsif val.is_a?(String)
        !!(['1', 't', 'T'].include?(val))
      elsif val.is_a?(Numeric)
        !!val.nonzero?
      else
        val
      end
    when /^int/i
      val.to_i
    else
      val
    end
  end

  #  Since we want false to be a valid stored value, we have to do the same as
  #  <code>validates_presence_of :value</code>, but just for nil values.
  def not_nil_value
    if @attributes['value'].nil?
      errors.add(:value, ' cannot be nil')
    end
  end

  def serialize?
    basic_type.nil? or basic_type.empty? or basic_type !~ /^str/i
  end

  def serialize val
    serialize? ? YAML.dump(val) : val
  end
end
