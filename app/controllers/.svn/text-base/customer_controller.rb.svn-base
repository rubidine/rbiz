class CustomerController < ApplicationController

  # don't log the passphrase
  filter_parameter_logging "passphrase"

  layout 'cart'
  helper :cart_common

  def login_post
    u = Customer.find_by_email(params[:user][:email])
    if u and u.passphrase_eql?(params[:user][:passphrase])
      u.update_attribute :last_login, Time.now

      # recover any old carts they had laying around
      old_cart = u.carts.find_by_sold_at(nil)
      new_cart = session[:cart_id] ? Cart.find(session[:cart_id]) : nil
      if new_cart and new_cart.customer and new_cart.customer != u
        new_cart = nil
      end

      if old_cart and !old_cart.line_items.empty?

        # if they have a new cart from this session that belongs to them
        # move the items from the old cart to this one.
        #
        # if they don't have a new cart in this session (or its empty)
        # then just move the old one back into the session
        if new_cart and !new_cart.line_items.empty?
          flash[:info] = "Found an abandoned cart from a previous visit,
                          the contents have been added to your current cart."
          old_cart.line_items.each do |li|
            new_cart.line_items << li
          end
        else
          session[:cart_id] = old_cart.id
          new_cart = old_cart
        end
      end

      new_cart ||= Cart.create(:customer => u)

      new_cart.customer = u

      new_cart.save

      session[:customer_id] = u.id
      session[:cart_id] = new_cart.id

      url = session[:redirect_to] || '/'
      if u.reset_password?
        flash[:notice] = "Please change your password"
        url = {:action=>'change_password'}
      end
      redirect_to url
      return
    elsif u
      flash[:warning] = "Unable to login.  Please provide a valid passphrase."
    else
      @u = Customer.new(params[:user])
      if @u.save

        new_cart = session[:cart_id] ? Cart.find(session[:cart_id]) : nil
        if new_cart and new_cart.customer and new_cart.customer != @u
          new_cart = nil
        end
        new_cart ||= Cart.create(:customer => @u)

        new_cart.customer = @u

        new_cart.save

        session[:customer_id] = @u.id
        session[:cart_id] = new_cart.id

        flash[:notice] = "Customer account created"
        redirect_to session[:redirect_to] || '/'
        return
      else
        flash[:warning] = "Unable to create account.<br/>
                          #{@u.errors.full_messages.join('<br/>')}"
      end
    end
    render :action => 'login'
  end

  def password_request
    if request.post?
      u = Customer.find_by_email(params[:user][:email])
      if u
        newpass = Customer.generate_random_passphrase
        u.passphrase = newpass
        CustomerNotifier.deliver_password_request u, newpass, request.host
        u.reset_password = true
        u.save
        flash[:notice] = "A new password has been sent to your email address."
        redirect_to :action=>'login'
      else
        flash[:warning] = "No account exists for #{params[:user][:email]}"
      end
    end
  end

  def change_password
    @customer = Customer.find(session[:customer_id])
    if request.post?
      if !@customer.reset_password? and !@customer.passphrase_eql?(params[:user][:old_passphrase])
        flash[:warning] = "Old passwords do not match."
      else
        @customer.passphrase = params[:user][:new_passphrase]
        @customer.reset_password = false
        @customer.save
        flash[:notice] = "Password updated."
        url = session[:redirect_to] || '/'
        redirect_to url
      end
    end
  end

  def logout
    session[:customer_id] = nil
    session[:cart_id] = nil
    redirect_to '/'
  end
end
