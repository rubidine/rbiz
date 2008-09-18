module CartOfficeAuthorization
  def self.included kls
    kls.send :before_filter, :office_login_requirement
  end

  def office_login_requirement
    # only login for office actions
    return true unless params[:controller] =~ /^office\//

    # if they are a customer and they are an admin
    return true if session[:customer_id] \
                and Customer.admin.find_by_id(session[:customer_id])

    redirect_to '/customer/login'
  end
end
