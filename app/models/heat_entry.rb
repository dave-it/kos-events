class HeatEntry < ApplicationRecord
  belongs_to :heat
  belongs_to :registration

  validates :registration_id, uniqueness: { scope: :heat_id }

  # Platz 1 und 2 kommen weiter.
  def advanced? = place.present? && place.between?(1, 2)
end
