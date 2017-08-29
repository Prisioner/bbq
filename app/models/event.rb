class Event < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions, source: :user

  validates :title, :address, :datetime, presence: true
  validates :title, length: { maximum: 255 }
end
