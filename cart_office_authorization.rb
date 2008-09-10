module CartOfficeAuthorization
  def self.included kls
    kls.send :before_filter, :office_login_requirement
  end

  def office_login_requirement
    unless session[:customer_id] and Customer.admin.find_by_id(session[:customer_id])
      redirect_to :controller => 'customer', :action => 'login'
    end
  end
end
