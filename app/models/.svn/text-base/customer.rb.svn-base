# A Customer purchases items.  We create a record for them so they can save
# addresses for quicker checkout and we can collect information to contact them
# (in case of an erorr in the billing or shipment fulfillment)
class Customer < ActiveRecord::Base
  validates_uniqueness_of :email

  validates_presence_of :email
  validates_presence_of :passphrase

  attr_protected :super_user

  has_many :addresses
  has_many :carts

  # The passphrase is stored as a one-way hash, so we compute
  # the hash here, when it is assigned.
  def passphrase= pp
    unless pp.nil? or pp.empty?
      write_attribute(:passphrase, Digest::MD5.hexdigest(pp))
    else
      write_attribute(:passphrase, nil)
    end
  end

  # Given a plain text passphrase, this method will compute
  # the one-way hash and compare it to what is stored.
  def passphrase_eql? pp
    passphrase.eql?(Digest::MD5.hexdigest(pp))
  end

  # When a password is reset and emailed, or if we automatically create a
  # Customer record we need to assign a passphrase.  This does it.
  def self.generate_random_passphrase
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_', '-']
    length = rand(6) + 10
    rv = ''
    length.times do
      rv << chars[rand(chars.length)]
    end
    rv
  end

  # Wrap reading the super_user? method
  # We can't alias it since super_user is built at call time and is not a real
  # method.
  def admin?
    super_user?
  end
end
