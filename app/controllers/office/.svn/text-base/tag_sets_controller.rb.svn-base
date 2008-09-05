class Office::TagSetsController < ApplicationController

  helper :cart_common
  helper :office
  layout 'office'

  def index
    @categories = TagSet.find(:all, :order => 'name')

    respond_to do |format|
      format.html
    end
  end

  def create
    @tag_set = TagSet.create(params[:tag_set])

    respond_to do |format|
      format.js
    end
  end

  def edit
    @tag_set = TagSet.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @tag_set = TagSet.find(params[:id])
    @tag_set.update_attributes(params[:tag_set])

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @tag_set = TagSet.find(params[:id])
    @tag_set.destroy
    respond_to do |format|
      format.js
    end
  end

end
