class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  validates :user_name, presence: true, unless: 'user.present?'
  validates :user_email, presence: true, format: { with: /\A[a-z\d\-_.]+@[a-z\d\-_.]+\z/i }, unless: 'user.present?'

  validates :user, uniqueness: { scope: :event_id }, if: 'user.present?'
  validates :user_email, uniqueness: { scope: :event_id }, unless: 'user.present?'
  validates :confirm_token, uniqueness: { case_sensitive: false }, allow_nil: true
  validate :email_taken, unless: 'user.present?'

  before_validation :user_email_downcase, unless: 'user.present?'
  before_create :confirmation

  scope :confirmed, -> { where(confirmed: true) }
  scope :not_confirmed, -> { where(confirmed: false) }

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

  def confirmed?
    confirmed
  end

  private

  def email_taken
    if User.find_by(email: user_email)
      errors.add(:user_email, :registered)
    end
  end

  def user_email_downcase
    user_email.downcase! if user_email.present?
  end

  def confirmation
    if user.present?
      self.confirmed = true
    else
      loop do
        new_confirm_token = SecureRandom.urlsafe_base64.to_s.downcase
        next if Subscription.find_by(confirm_token: new_confirm_token)
        self.confirm_token = new_confirm_token
        break
      end
    end
  end
end
