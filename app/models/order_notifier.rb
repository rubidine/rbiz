# A notification mechanism to let a Customer know their order is being processed
class OrderNotifier < ActionMailer::Base
  def receipt cart
    @from = CartConfig.get(:email_from, :office)
    @recipients = [cart.customer.email]
    @subject = "Receipt"
    @body['cart'] = cart
  end
end
