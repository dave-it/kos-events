# Sprachauswahl: ?locale=, Cookie, Vorgabe des Bereichs, Browser-Sprache, sonst Standard (de).
# Vorgabe: Fahrer sehen alles in ihrer Profilsprache (anfangs Englisch).
module Localization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
    helper_method :available_locales
  end

  private
    def available_locales = I18n.available_locales.map(&:to_s)

    # Sprachwahl merken. Laufzeit wie auf der Cookie-Seite angegeben.
    def remember_locale(locale)
      cookies[:locale] = { value: locale.to_s, expires: 1.year, same_site: :lax }
    end

    def switch_locale(&action)
      I18n.with_locale(requested_locale || I18n.default_locale, &action)
    end

    def requested_locale
      [ params[:locale], cookies[:locale], area_locale, browser_locale ].find { |l| available_locales.include?(l.to_s) }
    end

    # Von Controllern überschreibbar (z. B. Login: Englisch).
    def area_locale
      Current.user.rider&.locale || "en" if authenticated? && Current.user.rider_role?
    end

    def browser_locale
      request.env["HTTP_ACCEPT_LANGUAGE"].to_s.scan(/\A[a-z]{2}/).first
    end
end
