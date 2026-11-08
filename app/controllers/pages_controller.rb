# Öffentliche Seiten ohne Login.
class PagesController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session # damit eingeloggte Besucher ihren Bereich verlinkt sehen

  layout "public"

  def home
    @next_event = Event.published.upcoming.first
    @recent_events = Event.published.past.limit(3)
  end
end
