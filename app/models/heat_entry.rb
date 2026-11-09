class HeatEntry < ApplicationRecord
  belongs_to :heat
  belongs_to :registration

  validates :registration_id, uniqueness: { scope: :heat_id }

  # Spezialwerte aus dem Altbestand: 0 = DNF, -1 = DNS, -2 = DEQ.
  STATUSES = { 0 => "DNF", -1 => "DNS", -2 => "DEQ" }.freeze

  def status = STATUSES[place]

  # Platz 1 und 2 kommen weiter.
  def advanced? = place.present? && place.between?(1, 2)
end
