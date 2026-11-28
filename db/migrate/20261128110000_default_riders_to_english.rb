# Fahrer starten auf Englisch. Bisher hat niemand die Sprache selbst gewählt,
# "de" war nur der Vorgabewert, deshalb werden alle umgestellt.
class DefaultRidersToEnglish < ActiveRecord::Migration[8.1]
  def up
    change_column_default :riders, :locale, "en"
    execute "UPDATE riders SET locale = 'en'"
  end

  def down
    change_column_default :riders, :locale, "de"
  end
end
