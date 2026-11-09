class Registration < ApplicationRecord
  belongs_to :event
  belongs_to :category
  belongs_to :rider
  has_many :heat_entries, dependent: :destroy

  validates :rider_id, uniqueness: { scope: :category_id }
  validates :start_number, uniqueness: { scope: :category_id }, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :category_belongs_to_event

  scope :checked_in, -> { where.not(checked_in_at: nil) }

  # Zeitfahren: Sonderwerte in den Zeiten (Altbestand) stehen für DNS, DNF und DEQ.
  TIME_CODES = { 5_820_000 => "DNS", 5_880_000 => "DNF", 5_940_000 => "DEQ" }.freeze

  def valid_times = Array(qualification_times).compact.reject { |t| TIME_CODES.key?(t) || t <= 0 }.sort

  # Sortierschlüssel fürs Zeitfahren: schnellste, dann zweitschnellste Zeit. nil ohne gültige Zeit.
  def trial_sort_key
    times = valid_times
    [ times[0], times[1] || times[0] ] if times.any?
  end

  def checked_in? = checked_in_at.present?
  def waiver_signed? = waiver_signed_at.present?

  private
    def category_belongs_to_event
      errors.add(:category, :wrong_event) if category && category.event_id != event_id
    end
end
