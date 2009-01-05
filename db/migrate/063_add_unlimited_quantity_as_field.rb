class AddUnlimitedQuantityAsField < ActiveRecord::Migration
  def self.up
    add_column :products, :unlimited_quantity, :boolean
    add_column :product_option_selections, :unlimited_quantity, :boolean

    id = Product.find(:all, :conditions => {:quantity => -1}).collect(&:id)
    Product.update_all({:unlimited_quantity => true}, {:id => id})

    Variation.set_table_name 'product_option_selections'
    id = Variation.find(
           :all,
           :conditions => {:quantity => -1}
         ).collect(&:id)
    Variation.update_all({:unlimited_quantity => true}, {:id => id})
  end

  def self.down
  end
end
