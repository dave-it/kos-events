module Admin
  class RidersController < ApplicationController
    before_action :require_staff
    before_action :set_rider, only: %i[show invite]

    def index
      @riders = Rider.order(:lastname, :firstname)
    end

    def show
    end

    def new
      @rider = Rider.new
    end

    def create
      @rider = Rider.new(rider_params)
      if @rider.save
        send_invitation(@rider)
        redirect_to admin_rider_path(@rider), notice: "Fahrer angelegt und Einladung verschickt."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def invite
      if @rider.registered?
        redirect_to admin_rider_path(@rider), alert: "Fahrer hat bereits einen Zugang."
      else
        send_invitation(@rider)
        redirect_to admin_rider_path(@rider), notice: "Einladung erneut verschickt."
      end
    end

    private
      def set_rider = @rider = Rider.find(params[:id])

      def send_invitation(rider)
        invitation = rider.invite!(by: current_user)
        InvitationMailer.invite(invitation).deliver_later
      end

      def rider_params
        params.expect(rider: %i[firstname lastname email nickname nation birthday organization])
      end
  end
end
