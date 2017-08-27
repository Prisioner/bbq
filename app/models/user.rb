class User < ApplicationRecord
  has_many :events

  validates :name, presence: true, length: { maximum: 35 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :email, format: { with: /\A[a-z\d\-_.]+@[a-z\d\-_.]+\z/i }
end
