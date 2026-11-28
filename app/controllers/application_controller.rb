class ApplicationController < ActionController::Base
  include Authentication
  include Localization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  # Nicht vorhandene Inhalte zeigen die "Umbau"-Seite statt einer nackten Fehlermeldung.
  rescue_from ActiveRecord::RecordNotFound, with: :render_under_construction

  private
    def render_under_construction
      return head :not_found unless request.format.html?

      resume_session
      # Nach einem rescue_from ist die Sprachwahl des Requests schon zurückgesetzt.
      I18n.with_locale(requested_locale || I18n.default_locale) do
        render "shared/under_construction", layout: "public", status: :not_found, formats: :html
      end
    end

    def current_user = Current.user

    def require_staff
      head :forbidden unless current_user&.staff_role?
    end

    def require_guest
      head :forbidden unless current_user&.visitor_role? || current_user&.helper_role?
    end

    def require_member
      head :forbidden unless current_user&.member?
    end

    # Layout für Seiten, die öffentlich sind und eingeloggt in der App erscheinen.
    def public_or_app_layout = current_user&.member? ? "app" : "public"

    def require_rider
      # Auch ein Team-Konto mit Fahrerprofil (z. B. zum Testen) kommt ins Fahrerlager.
      head :forbidden unless current_user&.rider && (current_user.rider_role? || current_user.staff_role?)
    end
end
