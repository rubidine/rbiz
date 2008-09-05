class Office::OptionsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def create
    @option_set = OptionSet.find(params[:option_set_id])
    @option = @option_set.options.create(params[:option])
    @product = @option_set.product

    unless @option.new_record?
      @matrix_entries = []
      @product.option_matrix.reject do |x|
        x.any?{|y| y.option_set_id == @option_set.id and y != @option}
      end.each do |sel|
        pos = @product.product_option_selections.create(:quantity=>0)
        sel.each do |opt|
          pos.options << opt
        end
        pos.save
        @matrix_entries << pos
      end
    end
  end

  def destroy
    @option = Option.find(params[:id])
    opos = @option.product_option_selections.dup
    @option.destroy
    opos.each{|x| x.destroy}
  end
end
