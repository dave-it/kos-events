# Bereich für Besucher: Überblick über kommende Events und Ergebnisse.
class GuestController < ApplicationController
  before_action :require_visitor

  def show
    @upcoming = Event.published.where("starts_at >= ?", Time.current.beginning_of_day).order(:starts_at)
    @recent = Event.published.where("starts_at < ?", Time.current.beginning_of_day).order(starts_at: :desc).limit(5)
  end
end
