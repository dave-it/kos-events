class Category < ApplicationRecord
  belongs_to :event
  has_many :registrations, dependent: :restrict_with_error
  has_many :heats, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :event_id }

  # Heatbäume (Hauptfeld und Last Chance Qualifier) mit allen nötigen Daten vorgeladen.
  def brackets
    loaded = heats.includes(heat_entries: { registration: :rider }).to_a
    { main: HeatBracket.from_heats(loaded.reject(&:lcq?)), lcq: HeatBracket.from_heats(loaded.select(&:lcq?)) }
  end
end
