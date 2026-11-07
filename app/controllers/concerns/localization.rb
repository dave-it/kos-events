# Sprachauswahl: ?locale=, Cookie, Browser-Sprache, sonst Standard (de).
module Localization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
    helper_method :available_locales
  end

  private
    def available_locales = I18n.available_locales.map(&:to_s)

    def switch_locale(&action)
      I18n.with_locale(requested_locale || I18n.default_locale, &action)
    end

    def requested_locale
      [ params[:locale], cookies[:locale], browser_locale ].find { |l| available_locales.include?(l.to_s) }
    end

    def browser_locale
      request.env["HTTP_ACCEPT_LANGUAGE"].to_s.scan(/\A[a-z]{2}/).first
    end
end
