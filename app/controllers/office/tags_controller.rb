class Office::TagsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def index
    @tags = Tag.find(
              :all,
              :conditions => {:tag_set_id => params[:tag_set_id]},
              :order => 'position'
            )
    respond_to do |format|
      format.js
    end
  end

  # This is called from product editing and from tag_set editing
  # we use params[:product_id] to distinguish the two cases
  def create
    params[:tag][:tag_set_id] ||= params[:tag_set_id]
    @tag = Tag.create(params[:tag])
    respond_to do |format|
      format.js
    end
  end

  def edit
    @tag = Tag.find(params[:id], :include => [:tag_set])
    respond_to do |format|
      format.js
    end
  end

  # can be called for reorder or name change
  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_to do |format|
      format.js
    end
  end
end
