class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :subscriptions, dependent: :destroy
  has_many :photos, dependent: :nullify

  validates :name, presence: true, length: { maximum: 35 }

  after_commit :link_subscriptions, on: :create

  mount_uploader :avatar, AvatarUploader

  private

  def link_subscriptions
    Subscription.where(user_id: nil, user_email: self.email).update_all(user_id: self.id)
    self.subscriptions.not_confirmed.each do |subscription|
      subscription.update(confirmed: true)
      EventMailer.subscription(subscription.event, subscription).deliver_now
    end
  end
end
