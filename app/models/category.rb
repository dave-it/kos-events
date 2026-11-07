class Category < ApplicationRecord
  belongs_to :event
  has_many :registrations, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :event_id }
end
