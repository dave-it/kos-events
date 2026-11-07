class Registration < ApplicationRecord
  belongs_to :event
  belongs_to :category
  belongs_to :rider

  validates :rider_id, uniqueness: { scope: :event_id, message: "ist für dieses Event bereits angemeldet" }
  validates :start_number, uniqueness: { scope: :event_id }, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :category_belongs_to_event

  scope :checked_in, -> { where.not(checked_in_at: nil) }

  def checked_in? = checked_in_at.present?
  def waiver_signed? = waiver_signed_at.present?

  private
    def category_belongs_to_event
      errors.add(:category, "gehört nicht zu diesem Event") if category && category.event_id != event_id
    end
end
