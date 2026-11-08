require "csv"

# Importiert einen Event-Export aus dem alten kos (CSV-Dateien aus `\copy ... csv header`).
# Erwartet im Verzeichnis: events, categories, riders, eventriders, heats, heatriders (.csv).
# Wiederholbar: Datensätze werden über legacy_id (bzw. E-Mail bei Fahrern) wiedergefunden.
class LegacyImport
  FILES = %w[events categories riders eventriders heats heatriders].freeze

  Result = Struct.new(:counts, :warnings, keyword_init: true)

  def initialize(dir, publish: false, dry_run: false)
    @dir = Pathname(dir)
    @publish = publish
    @dry_run = dry_run
    @counts = Hash.new(0)
    @warnings = []
    @events = {}
    @categories = {}
    @riders = {}
    @registrations = {}
    @heats = {}
  end

  def call
    missing = FILES.reject { |f| @dir.join("#{f}.csv").exist? }
    raise ArgumentError, "Fehlende Dateien in #{@dir}: #{missing.join(', ')}" if missing.any?

    ActiveRecord::Base.transaction do
      import_events
      import_categories
      import_riders
      import_registrations
      import_heats
      import_heat_entries
      raise ActiveRecord::Rollback if @dry_run
    end
    Result.new(counts: @counts, warnings: @warnings)
  end

  private
    def rows(name) = CSV.read(@dir.join("#{name}.csv"), headers: true, encoding: "UTF-8")

    def import_events
      rows("events").each do |r|
        event = Event.find_or_initialize_by(legacy_id: r["id"])
        new_record = event.new_record?
        event.assign_attributes(
          name: r["name"], location: r["location"].presence, description: r["text"].presence,
          starts_at: utc(r["starts"]) || utc(r["created_at"]), ends_at: utc(r["ends"])
        )
        event.published = @publish if new_record
        save!(event, "Event #{r['id']}")
        @events[r["id"]] = event
        @counts[:events] += 1
      end
    end

    def import_categories
      rows("categories").each do |r|
        event = @events[r["event_id"]] or next warn("Kategorie #{r['id']}: Event #{r['event_id']} fehlt")
        category = Category.find_or_initialize_by(legacy_id: r["id"])
        category.assign_attributes(event: event, name: r["name"], position: r["order"].to_i,
                                   female: bool(r["female"]), juniors: bool(r["juniors"]))
        save!(category, "Kategorie #{r['id']}")
        @categories[r["id"]] = category
        @counts[:categories] += 1
      end
    end

    def import_riders
      rows("riders").each do |r|
        rider = Rider.find_by(legacy_id: r["id"]) || Rider.find_by(email: r["email"].to_s.strip.downcase) || Rider.new
        rider.legacy_id ||= r["id"]
        rider.assign_attributes(
          firstname: r["firstname"], lastname: r["lastname"], nickname: r["nickname"].presence,
          female: bool(r["female"]), nation: r["nation"].presence, birthday: r["birthday"].presence,
          email: r["email"], organization: r["organization"].presence, info: r["info"].presence
        )
        if save!(rider, "Fahrer #{r['id']} (#{r['firstname']} #{r['lastname']})")
          @riders[r["id"]] = rider
          @counts[:riders] += 1
        end
      end
    end

    def import_registrations
      rows("eventriders").each do |r|
        category = @categories[r["category_id"]] or next warn("Anmeldung #{r['id']}: Kategorie #{r['category_id']} fehlt")
        rider = @riders[r["rider_id"]] or next warn("Anmeldung #{r['id']}: Fahrer #{r['rider_id']} fehlt")
        reg = Registration.find_or_initialize_by(legacy_id: r["id"])
        reg.assign_attributes(
          event: category.event, category: category, rider: rider,
          start_number: r["number"].presence, trial_number: r["trial_number"].presence,
          qualification_times: times(r["qualification_times"]), points: r["points"].presence,
          waiver_signed_at: (utc(r["created_at"]) if bool(r["waiver"])),
          checked_in_at: (utc(r["updated_at"]) if bool(r["checked_in"]))
        )
        keep_without_number_if_taken(reg, r)
        if save!(reg, "Anmeldung #{r['id']}")
          @registrations[r["id"]] = reg
          @counts[:registrations] += 1
        end
      end
    end

    def import_heats
      rows("heats").each do |r|
        category = @categories[r["category_id"]] or next warn("Heat #{r['id']}: Kategorie #{r['category_id']} fehlt")
        heat = Heat.find_or_initialize_by(legacy_id: r["id"])
        heat.assign_attributes(category: category, round: r["heatround"].to_i, number: r["heatnumber"].to_i,
                               lcq: bool(r["lcq"]), finished: bool(r["finished"]))
        if save!(heat, "Heat #{r['id']}")
          @heats[r["id"]] = heat
          @counts[:heats] += 1
        end
      end
    end

    def import_heat_entries
      rows("heatriders").each do |r|
        heat = @heats[r["heat_id"]] or next warn("Heat-Eintrag #{r['id']}: Heat #{r['heat_id']} fehlt")
        reg = @registrations[r["eventrider_id"]] or next warn("Heat-Eintrag #{r['id']}: Anmeldung #{r['eventrider_id']} fehlt")
        entry = HeatEntry.find_or_initialize_by(legacy_id: r["id"])
        entry.assign_attributes(heat: heat, registration: reg, place: r["finished"].presence,
                                gate_pick: r["gate_pick"].presence, gate_color: r["gate_color"].presence)
        @counts[:heat_entries] += 1 if save!(entry, "Heat-Eintrag #{r['id']}")
      end
    end

    # Doppelt vergebene Startnummer im Altbestand: Anmeldung (und Ergebnisse) behalten, Nummer weglassen.
    def keep_without_number_if_taken(reg, row)
      return unless reg.invalid? && reg.errors.of_kind?(:start_number, :taken)

      warn("Anmeldung #{row['id']}: Startnummer #{reg.start_number} in der Kategorie doppelt vergeben, ohne Nummer importiert")
      reg.start_number = nil
    end

    def save!(record, label)
      return true if record.save

      warn("#{label}: #{record.errors.full_messages.to_sentence}")
      false
    end

    def warn(message)
      @warnings << message
      nil
    end

    def bool(value) = ActiveModel::Type::Boolean.new.cast(value) || false

    # Der alte kos speichert Zeiten ohne Zeitzone in UTC.
    def utc(value) = value.present? ? ActiveSupport::TimeZone["UTC"].parse(value) : nil

    # Zeiten liegen als YAML-Liste in Millisekunden vor ("---\n- 32740\n- 32790\n").
    def times(value)
      list = YAML.safe_load(value.to_s)
      list.is_a?(Array) ? list.map(&:to_i) : []
    rescue Psych::Exception
      []
    end
end
