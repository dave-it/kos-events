class Event < ApplicationRecord
  has_many :categories, -> { order(:position, :name) }, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :riders, through: :registrations

  validates :name, :starts_at, presence: true
  validate :ends_after_start

  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where("starts_at >= ?", Time.current.beginning_of_day).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current.beginning_of_day).order(starts_at: :desc) }

  private
    def ends_after_start
      errors.add(:ends_at, "muss nach dem Beginn liegen") if ends_at && starts_at && ends_at < starts_at
    end
end
