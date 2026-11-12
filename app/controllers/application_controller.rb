class ApplicationController < ActionController::Base
  include Authentication
  include Localization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private
    def current_user = Current.user

    def require_staff
      head :forbidden unless current_user&.staff_role?
    end

    def require_visitor
      head :forbidden unless current_user&.visitor_role?
    end

    def require_rider
      head :forbidden unless current_user&.rider_role? && current_user.rider
    end
end
