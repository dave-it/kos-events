namespace :legacy do
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
