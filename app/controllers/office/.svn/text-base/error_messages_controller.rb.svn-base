class Office::ErrorMessagesController < ApplicationController
  helper :cart_common
  helper :office
  layout 'office'

  def index
    @error_messages = ErrorMessage.paginate(
                        :page => (params[:page] || 1).to_i,
                        :per_page => 30,
                        :order => 'created_at desc'
                      )
  end

end
