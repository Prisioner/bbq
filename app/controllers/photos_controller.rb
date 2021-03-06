class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_photo, only: :destroy

  def create
    @new_photo = @event.photos.build(photo_params)
    @new_photo.user = current_user

    if pincode_required?
      redirect_to @event, alert: I18n.t('controllers.photos.error')
    elsif @new_photo.save
      notify_subscribers(@event, @new_photo)
      redirect_to @event, notice: I18n.t('controllers.photos.created')
    else
      render 'events/show', alert: I18n.t('controllers.photos.error')
    end
  end

  def destroy
    message = { notice: I18n.t('controllers.photos.destroyed') }

    if current_user_can_edit?(@photo)
      @photo.destroy
    else
      message = { alert: I18n.t('controllers.photos.error') }
    end

    redirect_to @event, message
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_photo
    @photo = @event.photos.find(params[:id])
  end

  def photo_params
    params.fetch(:photo, {}).permit(:photo)
  end

  def notify_subscribers(event, photo)
    all_emails = (event.subscriptions.confirmed.map(&:user_email) + [event.user.email]).uniq
    all_emails -= [current_user.email]

    all_emails.each do |email|
      EventMailer.photo(event, photo, email).deliver_now
    end
  end

  def pincode_required?
    @event.user != current_user &&
      @event.pincode.present? &&
      !@event.pincode_valid?(cookies.permanent["events_#{@event.id}_pincode"])
  end
end
