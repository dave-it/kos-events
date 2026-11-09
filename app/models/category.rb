class Category < ApplicationRecord
  belongs_to :event
  has_many :registrations, dependent: :restrict_with_error
  has_many :heats, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :event_id }

  # Platzierung im Zeitfahren: { registration_id => 1, ... }, nur für Fahrer mit gültiger Zeit.
  def trial_ranks
    registrations.filter_map { |r| (key = r.trial_sort_key) && [ r.id, key ] }
                 .sort_by(&:last).each_with_index.to_h { |(id, _), i| [ id, i + 1 ] }
  end

  # Heatbäume (Hauptfeld und Last Chance Qualifier) mit allen nötigen Daten vorgeladen.
  def brackets
    loaded = heats.includes(heat_entries: { registration: :rider }).to_a
    ranks = trial_ranks
    { main: HeatBracket.from_heats(loaded.reject(&:lcq?), ranks), lcq: HeatBracket.from_heats(loaded.select(&:lcq?), ranks) }
  end
end
