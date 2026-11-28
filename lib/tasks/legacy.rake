namespace :legacy do
  desc "Leere Heats aus früheren Importen löschen: [DRY_RUN=1]"
  task prune_empty_heats: :environment do
    heats = LegacyImport.empty_heats.includes(category: :event).order(:category_id, :lcq, :round, :number).to_a
    heats.group_by { |h| [ h.event.name, h.category.name, h.lcq? ? "LCQ" : "Hauptfeld", h.round ] }.each do |(event, category, bracket, round), group|
      puts "  #{event} / #{category} / #{bracket} / Runde #{round}: #{group.size} Heats"
    end
    if ENV["DRY_RUN"] == "1"
      puts "Testlauf: #{heats.size} leere Heats gefunden, nichts gelöscht."
    else
      heats.each(&:destroy!)
      puts "#{heats.size} leere Heats gelöscht."
    end
  end

  desc "Event-Export aus dem alten kos importieren: DIR=pfad [PUBLISH=1] [DRY_RUN=1]"
  task import: :environment do
    dir = ENV.fetch("DIR") { abort "Bitte DIR=/pfad/zum/export angeben" }
    result = LegacyImport.new(dir, publish: ENV["PUBLISH"] == "1", dry_run: ENV["DRY_RUN"] == "1").call
    puts(ENV["DRY_RUN"] == "1" ? "Testlauf (nichts gespeichert):" : "Import abgeschlossen:")
    result.counts.each { |k, v| puts "  #{k}: #{v}" }
    puts "Warnungen (#{result.warnings.size}):" if result.warnings.any?
    result.warnings.each { |w| puts "  - #{w}" }
  end
end
