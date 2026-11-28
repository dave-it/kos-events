class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :rider, dependent: :nullify
  has_many :chat_messages, dependent: :nullify
  has_many :chat_reads, dependent: :delete_all

  # staff = Organisatoren, helper = Helfer beim Weltcup-Event, visitor = Besucher.
  enum :role, { rider: "rider", staff: "staff", helper: "helper", visitor: "visitor" }, default: :rider, suffix: :role

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  # Fahrer mit Profil und Organisatoren haben den vollen App-Bereich.
  def member? = staff_role? || (rider_role? && rider.present?)

  # Name im Chat: Fahrer nur mit abgekürztem Nachnamen (Schutz von Minderjährigen).
  def display_name
    return "#{rider.firstname} #{rider.lastname.first}." if rider_role? && rider

    email_address.split("@").first.split(/[._-]+/).map(&:capitalize).join(" ")
  end
end
