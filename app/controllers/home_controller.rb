class HomeController < ApplicationController
  def index
    if current_user.staff_role?
      redirect_to admin_riders_path
    else
      redirect_to hub_path
    end
  end
end
