# Erster Staff-Zugang für die Entwicklung. In Produktion per Konsole anlegen.
if Rails.env.development?
  User.find_or_create_by!(email_address: "admin@example.com") do |u|
    u.password = "password123"
    u.role = :staff
  end
end

# Inhalte der bisherigen Webseite ice-cross.at. Nur anlegen, nie überschreiben:
# Änderungen im Team-Bereich bleiben erhalten.
content = Rails.root.join("db/content")

YAML.safe_load_file(content.join("pages.yml")).each do |attrs|
  Page.find_or_create_by!(slug: attrs.fetch("slug")) { |page| page.assign_attributes(attrs) }
end

YAML.safe_load_file(content.join("events.yml"), permitted_classes: [ Time ]).each do |attrs|
  Event.find_or_create_by!(name: attrs.fetch("name")) do |event|
    event.assign_attributes(attrs.transform_values { |v| v })
  end
end
