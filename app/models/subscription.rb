class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  validates :user_name, presence: true, unless: 'user.present?'
  validates :user_email, presence: true, format: { with: /\A[a-z\d\-_.]+@[a-z\d\-_.]+\z/i }, unless: 'user.present?'

  validates :user, uniqueness: { scope: :event_id }, if: 'user.present?'
  validates :user_email, uniqueness: { scope: :event_id }, unless: 'user.present?'
  validate :email_taken, unless: 'user.present?'

  before_validation :user_email_downcase, unless: 'user.present?'

  def user_name
    if user.present?
      user.name
    else
      super
    end
  end

  def user_email
    if user.present?
      user.email
    else
      super
    end
  end

  def email_taken
    if User.find_by(email: user_email)
      errors.add(:user_email, :registered)
    end
  end

  def user_email_downcase
    user_email.downcase! if user_email.present?
  end
end
