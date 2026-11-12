class HomeController < ApplicationController
  def index
    if current_user.staff_role?
      redirect_to admin_events_path
    elsif current_user.visitor_role?
      redirect_to guest_path
    else
      redirect_to hub_path
    end
  end
end
