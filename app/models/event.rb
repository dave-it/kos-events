class Event < ApplicationRecord
  has_many :categories, -> { order(:position, :name) }, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :riders, through: :registrations
  has_many :heats, through: :categories

  validates :name, :starts_at, presence: true
  validates :registration_url, format: { with: /\Ahttps?:\/\/\S+\z/ }, allow_blank: true
  validate :ends_after_start

  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where("starts_at >= ?", Time.current.beginning_of_day).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current.beginning_of_day).order(starts_at: :desc) }

  def info(locale = I18n.locale)
    (locale.to_s == "de" ? info_de.presence || info_en : info_en.presence || info_de)
  end

  def registration_open?
    registration_url.present? && (registration_deadline.nil? || registration_deadline.future?)
  end

  private
    def ends_after_start
      errors.add(:ends_at, :after_start) if ends_at && starts_at && ends_at < starts_at
    end
end
