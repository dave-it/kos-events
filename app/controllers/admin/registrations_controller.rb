module Admin
  class RegistrationsController < ApplicationController
    before_action :require_staff
    before_action :set_event

    def create
      registration = @event.registrations.new(registration_params)
      if registration.save
        redirect_to admin_event_path(@event), notice: "Fahrer angemeldet."
      else
        redirect_to admin_event_path(@event), alert: registration.errors.full_messages.to_sentence
      end
    end

    def update
      registration = @event.registrations.find(params[:id])
      if registration.update(params.expect(registration: [ :start_number ]))
        redirect_to admin_event_path(@event), notice: "Startnummer gespeichert."
      else
        redirect_to admin_event_path(@event), alert: registration.errors.full_messages.to_sentence
      end
    end

    def check_in
      registration = @event.registrations.find(params[:id])
      registration.update!(checked_in_at: registration.checked_in? ? nil : Time.current)
      redirect_to admin_event_path(@event), notice: registration.checked_in? ? "Eingecheckt." : "Check-in zurückgenommen."
    end

    def destroy
      @event.registrations.find(params[:id]).destroy
      redirect_to admin_event_path(@event), notice: "Anmeldung entfernt.", status: :see_other
    end

    private
      def set_event = @event = Event.find(params[:event_id])

      def registration_params
        params.expect(registration: %i[rider_id category_id])
      end
  end
end
