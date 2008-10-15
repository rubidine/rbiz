# Customers can request their password to be reset and mailed to them
class CustomerNotifier < ActionMailer::Base

  self.template_root = File.join(File.dirname(__FILE__), '..', 'views')

  def password_request user, newpass, host
    @from = CartConfig.get(:user_email_from)
    @recipients = [user.email]
    @subject = "Password Reset"
    @body['password'] = newpass
    @body['host'] = host
  end

end
