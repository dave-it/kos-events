class Heat < ApplicationRecord
  belongs_to :category
  has_many :heat_entries, -> { order(:place) }, dependent: :destroy
  has_many :registrations, through: :heat_entries

  validates :round, :number, presence: true

  scope :main, -> { where(lcq: false) }
  scope :lcq, -> { where(lcq: true) }
  scope :ordered, -> { order(:round, :number) }

  delegate :event, to: :category
end
