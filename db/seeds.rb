# Erster Staff-Zugang für die Entwicklung. In Produktion per Konsole anlegen.
if Rails.env.development?
  User.find_or_create_by!(email_address: "admin@example.com") do |u|
    u.password = "password123"
    u.role = :staff
  end
end
