
class OptionSetPerProduct < ActiveRecord::Migration
  def self.up
    # removed in model, but needed for migration
    OptionSet.send :has_and_belongs_to_many, :products

    add_column :option_sets, :product_id, :integer
    add_column :options, :price_adjustment, :integer
    add_column :options, :has_input, :boolean
    remove_column :product_option_selections, :price_adjustment

    aos = OptionSet.find(:all)
    aos.each do |os|
      os.products.each do |p|
        new_os = OptionSet.new(
                   :product_id => p.id,
                   :name => os.name
                 )
        new_os.save
        unless new_os.new_record?
          os.options.each do |o|
            new_o = Option.new(
                      :option_set_id => new_os.id,
                      :name => o.name,
                      :price_adjustment => 0,
                      :has_input => false
                    )
            new_o.save
            if new_o.new_record?
              STDERR.puts "Can't add option '#{new_o.name}' to set '#{new_os.name}'"
            end
          end
        else
          STDERR.puts "Cant create set '#{new_os.name}' on product #{p.id}"
          STDERR.puts "=> #{new_os.errors.full_messages.join(', ')}"
          STDERR.puts "=> #{os.options.collect(&:name).join(',')}"
        end
      end
      os.destroy
    end

    drop_table :option_sets_products

  end

  def self.down
    remove_column :option_sets, :product_id
    remove_column :options, :price_adjustment
    remove_column :options, :has_input
    add_column :product_option_selections, :price_adjustment, :integer

    create_table :option_sets_products, :id => false do |t|
      t.column :product_id, :integer
      t.column :option_set_id, :integer
    end
  end
end
