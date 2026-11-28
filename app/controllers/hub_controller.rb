# Fahrerlager: persönlicher Bereich für eingeladene Fahrer.
class HubController < ApplicationController
  layout "app"
  before_action :require_rider
  before_action :set_rider

  def show
    @registrations = @rider.registrations.includes(:event, :category).joins(:event).order("events.starts_at DESC").to_a
    @next_event = Event.published.upcoming.first
    @next_registrations = @registrations.select { |r| r.event_id == @next_event&.id }
    @announcements = ChatMessage.joins(:chat_room).merge(ChatRoom.readable_by(current_user).where(organizers_only: true))
                                .includes(:chat_room, user: :rider).order(id: :desc).limit(3)
  end

  def profile
  end

  def edit
  end

  def update
    if @rider.update(profile_params)
      cookies.permanent[:locale] = { value: @rider.locale, same_site: :lax }
      redirect_to profile_hub_path, notice: t("flash.hub.saved", locale: @rider.locale)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_rider = @rider = current_user.rider

    def profile_params
      params.expect(rider: %i[firstname lastname nickname nation birthday organization info public_profile locale])
    end
end
