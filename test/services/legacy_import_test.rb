require "test_helper"

class LegacyImportTest < ActiveSupport::TestCase
  DIR = Rails.root.join("test/fixtures/files/legacy")

  test "importiert Event, Kategorien, Fahrer, Anmeldungen, Heats und Platzierungen" do
    result = LegacyImport.new(DIR).call

    assert_equal 1, result.counts[:events]
    assert_equal 2, result.counts[:categories]
    assert_equal 3, result.counts[:riders]
    assert_equal 5, result.counts[:registrations]
    assert_equal 2, result.counts[:heats]
    assert_equal 3, result.counts[:heat_entries]

    event = Event.find_by!(legacy_id: 900)
    assert_equal "Test Cup 2026", event.name
    assert_not event.published?, "Importierte Events sind zunächst Entwürfe"
    assert_equal Time.utc(2026, 1, 30, 15), event.starts_at.utc
  end

  test "Fahrerdaten, Zeiten und Check-in werden übernommen" do
    LegacyImport.new(DIR).call

    eva = Rider.find_by!(email: "eva@example.com")
    assert_equal "Evi", eva.nickname
    assert eva.female?
    assert_equal "GER", eva.nation
    assert_not eva.public_profile?, "Importierte Profile sind nicht öffentlich"

    reg = Registration.find_by!(legacy_id: 930)
    assert_equal 7, reg.start_number
    assert_equal [ 32_740, 32_790 ], reg.qualification_times
    assert reg.checked_in?
    assert reg.waiver_signed?
    assert_equal [], Registration.find_by!(legacy_id: 931).qualification_times
  end

  test "Fahrer in zwei Kategorien, gleiche Nummer in verschiedenen Kategorien" do
    LegacyImport.new(DIR).call
    max = Rider.find_by!(email: "max@example.com")
    assert_equal 2, max.registrations.count
    assert_equal [ 7, 8 ], max.registrations.order(:start_number).pluck(:start_number)
    men = Category.find_by!(legacy_id: 910)
    women = Category.find_by!(legacy_id: 911)
    assert_equal 7, men.registrations.find_by!(legacy_id: 930).start_number
    assert_equal 7, women.registrations.find_by!(legacy_id: 931).start_number
  end

  test "Platzierungen und Heats" do
    LegacyImport.new(DIR).call
    heat = Heat.find_by!(legacy_id: 940)
    assert_equal [ 1, 2 ], heat.heat_entries.pluck(:place)
    assert heat.heat_entries.first.advanced?
    assert_not HeatEntry.find_by!(legacy_id: 952).advanced?
    assert heat.finished?
    assert_not heat.lcq?
  end

  test "ist wiederholbar ohne Duplikate" do
    LegacyImport.new(DIR).call
    assert_no_difference [ "Event.count", "Category.count", "Rider.count", "Registration.count", "Heat.count", "HeatEntry.count" ] do
      LegacyImport.new(DIR).call
    end
  end

  test "bestehender Fahrer wird über die E-Mail wiedergefunden" do
    existing = Rider.create!(firstname: "Max", lastname: "Muster", email: "MAX@example.com", nickname: "bleibt")
    LegacyImport.new(DIR).call
    assert_equal existing.id, Registration.find_by!(legacy_id: 930).rider_id
    assert_equal 1, Rider.where(email: "max@example.com").count
  end

  test "ungültige Datensätze werden gemeldet und übersprungen" do
    result = LegacyImport.new(DIR).call
    assert_nil Rider.find_by(legacy_id: 922)
    assert(result.warnings.any? { |w| w.include?("Fahrer 922") })
  end

  test "Testlauf speichert nichts" do
    assert_no_difference [ "Event.count", "Rider.count", "Registration.count" ] do
      result = LegacyImport.new(DIR, dry_run: true).call
      assert_equal 5, result.counts[:registrations]
    end
  end

  test "publish veröffentlicht neue Events" do
    LegacyImport.new(DIR, publish: true).call
    assert Event.find_by!(legacy_id: 900).published?
  end

  test "fehlende Dateien werden klar gemeldet" do
    error = assert_raises(ArgumentError) { LegacyImport.new(Rails.root.join("test/fixtures/files")).call }
    assert_match "events", error.message
  end
end
