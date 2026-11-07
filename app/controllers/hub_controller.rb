# Rider Hub: persönlicher Bereich für eingeladene Fahrer.
class HubController < ApplicationController
  before_action :require_rider

  def show
    @rider = current_user.rider
  end

  def edit
    @rider = current_user.rider
  end

  def update
    @rider = current_user.rider
    if @rider.update(profile_params)
      redirect_to hub_path, notice: "Profil gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.expect(rider: %i[firstname lastname nickname nation birthday organization info public_profile])
    end
end
