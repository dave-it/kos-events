module Admin
  class EventsController < ApplicationController
    before_action :require_staff
    before_action :set_event, only: %i[show edit update destroy]

    def index
      @events = Event.order(starts_at: :desc)
    end

    def show
      @categories = @event.categories.includes(registrations: :rider)
      @available_riders = Rider.where.not(id: @event.registrations.select(:rider_id)).order(:lastname, :firstname)
    end

    def new
      @event = Event.new(starts_at: Time.current.change(hour: 10))
    end

    def create
      @event = Event.new(event_params)
      if @event.save
        redirect_to admin_event_path(@event), notice: "Event angelegt."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @event.update(event_params)
        redirect_to admin_event_path(@event), notice: "Event gespeichert."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_events_path, notice: "Event gelöscht.", status: :see_other
    end

    private
      def set_event = @event = Event.find(params[:id])

      def event_params
        params.expect(event: %i[name location description starts_at ends_at published])
      end
  end
end
