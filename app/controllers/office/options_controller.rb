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
      @product.option_matrix(@option_set).each do |sel|
        pos = @product.variations.create(:quantity=>0)
        sel.each do |opt|
          pos.options << Option.find(opt.id)
        end
        pos.options << @option
        pos.save
        @matrix_entries << pos
      end
    end
  end

  def destroy
    @option = Option.find(params[:id])
    opos = @option.variations.dup
    @option.destroy
    opos.each{|x| x.destroy}
  end
end
