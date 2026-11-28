# Fragen und Antworten für den App-Bereich, aus den Inhalten der Webseite.
class InfoController < ApplicationController
  layout "app"
  before_action :require_member

  def show
    @event = Event.published.upcoming.first
    @topics = InfoDirectory.new(event: @event, pages: Page.published.order(:position, :slug).to_a).topics
  end
end
