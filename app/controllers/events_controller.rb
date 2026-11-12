# Öffentliche Eventübersicht und Ergebnisse (nur veröffentlichte Events).
class EventsController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session
  layout "public"

  def index
    @upcoming = Event.published.upcoming
    @past = Event.published.past
  end

  def show
    @event = Event.published.find(params[:id])
    @categories = @event.categories.select { |c| c.heats.exists? }
    @category = @categories.find { |c| c.id == params[:category].to_i } || @categories.first
    @brackets = @category&.brackets
    @view = params[:view] == "list" ? "list" : "tree"
    @standings = CategoryStandings.new(@brackets[:main], @brackets[:lcq]) if @category && @view == "list"
  end
end
