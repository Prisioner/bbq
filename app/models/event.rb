class Event < ApplicationRecord
  validates :title, :address, :datetime, presence: true
  validates :title, length: { maximum: 255 }
end
