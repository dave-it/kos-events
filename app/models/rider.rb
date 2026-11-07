class Rider < ApplicationRecord
  belongs_to :user, optional: true
  has_many :invitations, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :publicly_visible, -> { where(public_profile: true) }

  before_save :track_public_consent, if: :public_profile_changed?

  def name = "#{firstname} #{lastname}"

  def registered? = user.present?

  ADULT_AGE = 18

  # Ohne Geburtstag gilt ein Fahrer aus Datenschutzgründen als minderjährig.
  def minor?(on: Date.current)
    return true if birthday.blank?

    age = on.year - birthday.year
    age -= 1 if on < birthday + age.years
    age < ADULT_AGE
  end

  # Name und Nation erscheinen in Ergebnissen immer, außer bei Minderjährigen
  # ohne Zustimmung.
  def public_name_visible?(on: Date.current) = !minor?(on: on) || public_profile?

  def public_name(on: Date.current)
    return name if public_name_visible?(on: on)

    "#{firstname.first}. #{lastname.first}."
  end

  def public_nation(on: Date.current)
    nation if public_name_visible?(on: on)
  end

  # Legt eine neue Einladung an und macht ältere offene Einladungen ungültig.
  def invite!(by:)
    transaction do
      invitations.pending.update_all(expires_at: Time.current)
      invitations.create!(email: email, invited_by: by)
    end
  end

  private
    # Zeitpunkt der Zustimmung festhalten, bei Widerruf löschen (DSGVO-Nachweis).
    def track_public_consent
      self.public_profile_consented_at = public_profile? ? Time.current : nil
    end
end
