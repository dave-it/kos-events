# Bereich für Besucher und Helfer: Überblick über kommende Events und Ergebnisse.
# Der eigene App-Bereich für beide Gruppen folgt, zuerst wird der für Fahrer gebaut.
class GuestController < ApplicationController
  layout "auth"
  before_action :require_guest

  def show
    @upcoming = Event.published.where("starts_at >= ?", Time.current.beginning_of_day).order(:starts_at)
    @recent = Event.published.where("starts_at < ?", Time.current.beginning_of_day).order(starts_at: :desc).limit(5)
  end
end
