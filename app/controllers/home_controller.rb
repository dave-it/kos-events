class HomeController < ApplicationController
  allow_unauthenticated_access only: :launch

  # Startpunkt der installierten App: angemeldet in den eigenen Bereich, sonst zur Webseite.
  def launch
    redirect_to resume_session ? start_path : root_path
  end

  def index
    if current_user.staff_role?
      redirect_to admin_events_path
    elsif current_user.visitor_role? || current_user.helper_role?
      redirect_to guest_path
    else
      redirect_to hub_path
    end
  end
end
