class SubscriptionMailer < ApplicationMailer

  def confirmation(subscription)
    email = subscription.user_email
    @name = subscription.user_name
    @event = subscription.event
    @subscription = subscription

    mail to: email, subject: "Подтверждение подписки на #{@event.title}"
  end
end
