class SubscriptionsController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_subscription, only: [:destroy]

  def create
    @new_subscription = @event.subscriptions.build(subscription_params)
    @new_subscription.user = current_user

    if @event.user == current_user
      redirect_to @event, alert: I18n.t('controllers.subscriptions.error')
    elsif @new_subscription.save

      if @new_subscription.confirmed?
        EventMailer.subscription(@event, @new_subscription).deliver_now
        message = { notice: I18n.t('controllers.subscriptions.created') }
      else
        SubscriptionMailer.confirmation(@new_subscription).deliver_now
        message = { notice: I18n.t('controllers.subscriptions.confirmation_required')}
      end

      redirect_to @event, message
    else
      render 'events/show', alert: I18n.t('controllers.subscriptions.error')
    end
  end

  def destroy
    message = { notice: I18n.t('controllers.subscriptions.destroyed') }

    if current_user_can_edit?(@subscription)
      @subscription.destroy
    else
      message = { alert: I18n.t('controllers.subscriptions.error') }
    end

    redirect_to @event, message
  end

  def confirm_email
    @subscription = Subscription.find_by(confirm_token: params[:confirm_token])
    if @subscription.blank?
      message = { alert: I18n.t('controllers.subscriptions.not_found') }
      redirect_to root_path, message
    else

      if @subscription.confirmed?
        message = { alert: I18n.t('controllers.subscriptions.already_confirmed') }
      else
        @subscription.update(confirmed: true)
        EventMailer.subscription(@subscription.event, @subscription).deliver_now
        message = { notice: I18n.t('controllers.subscriptions.confirmed') }
      end

      redirect_to @subscription.event, message
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_subscription
    @subscription = @event.subscriptions.find(params[:id])
  end

  def subscription_params
    params.fetch(:subscription, {}).permit(:user_email, :user_name)
  end
end
