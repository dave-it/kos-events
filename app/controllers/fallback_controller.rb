# Letzte Station für unbekannte Adressen: alte WordPress-Adressen von ice-cross.at werden
# weitergeleitet, alles andere zeigt die "Umbau"-Seite.
class FallbackController < ApplicationController
  allow_unauthenticated_access

  # alte Adresse => [ neues Ziel, Sprache der alten Seite ]
  PAGES = {
    "weltcup" => [ "/zuschauer", nil ],
    "preisliste" => [ "/preise", nil ],
    "preisliste_neu" => [ "/preise", nil ],
    "prices" => [ "/preise", "en" ],
    "training-en" => [ "/training", "en" ],
    "training-calendar" => [ "/training", nil ],
    "buchen" => [ "/training", nil ],
    "wp-booking-calendar" => [ "/training", nil ],
    "art-hotel-spielberg" => [ "/hotel", nil ],
    "partner-hotel-art-spielberg" => [ "/hotel", "en" ],
    "all-about-heats" => [ "/heats", nil ],
    "cookie-policy-eu" => [ "/cookies", nil ],
    "startseite" => [ "/", nil ],
    "startseite-english" => [ "/", "en" ],
    "home" => [ "/", "en" ]
  }.freeze

  # Alte Rennseiten zeigen auf das nächste Event.
  EVENT_PAGES = { "winterleiten_27" => nil, "race-2027" => "en", "atsx-250" => nil, "atsx-250-en" => "en" }.freeze

  def show
    segments = params[:path].to_s.downcase.split("/").compact_blank
    english = segments.first == "en" && segments.shift
    slug = segments.join("/")

    if EVENT_PAGES.key?(slug)
      redirect_to_event(english ? "en" : EVENT_PAGES[slug])
    elsif PAGES.key?(slug)
      target, locale = PAGES[slug]
      redirect_with_locale(target, english ? "en" : locale, :moved_permanently)
    elsif english && (slug.empty? || Page.published.exists?(slug: slug))
      redirect_with_locale("/#{slug}", "en", :moved_permanently)
    else
      render_under_construction
    end
  end

  private
    # Vorübergehend (302), weil sich das nächste Event ändert.
    def redirect_to_event(locale)
      event = Event.published.upcoming.first
      redirect_with_locale(event ? event_path(event) : events_path, locale, :found)
    end

    def redirect_with_locale(target, locale, status)
      redirect_to(locale ? "#{target}?locale=#{locale}" : target, status: status)
    end
end
