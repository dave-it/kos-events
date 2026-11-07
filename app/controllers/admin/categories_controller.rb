module Admin
  class CategoriesController < ApplicationController
    before_action :require_staff
    before_action :set_event

    def create
      category = @event.categories.new(category_params)
      if category.save
        redirect_to admin_event_path(@event), notice: "Kategorie angelegt."
      else
        redirect_to admin_event_path(@event), alert: category.errors.full_messages.to_sentence
      end
    end

    def destroy
      category = @event.categories.find(params[:id])
      if category.destroy
        redirect_to admin_event_path(@event), notice: "Kategorie gelöscht.", status: :see_other
      else
        redirect_to admin_event_path(@event), alert: "Kategorie hat noch Anmeldungen.", status: :see_other
      end
    end

    private
      def set_event = @event = Event.find(params[:event_id])

      def category_params
        params.expect(category: %i[name position female juniors])
      end
  end
end
