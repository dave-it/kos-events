class Invitation < ApplicationRecord
  EXPIRES_IN = 14.days
  ROLES = %w[rider staff visitor].freeze

  belongs_to :rider, optional: true
  belongs_to :invited_by, class_name: "User"

  has_secure_token :token

  before_validation :set_expiry, on: :create

  validates :email, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :rider, presence: true, if: -> { role == "rider" }
  validates :locale, inclusion: { in: ->(_) { I18n.available_locales.map(&:to_s) } }

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  def self.find_pending(token)
    pending.find_by(token: token)
  end

  def accepted? = accepted_at.present?

  # Sprache der Einladung: die des Fahrers, sonst die beim Anlegen gewählte.
  def language = rider&.locale || locale

  # Legt den Account mit der eingeladenen Rolle an. Fahrer werden mit ihrem Rider verknüpft.
  def accept!(password:, password_confirmation:)
    transaction do
      user = User.new(email_address: email, password: password,
                      password_confirmation: password_confirmation, role: role)
      user.save!
      rider&.update!(user: user)
      update!(accepted_at: Time.current)
      user
    end
  end

  private
    def set_expiry
      self.expires_at ||= EXPIRES_IN.from_now
    end
end
