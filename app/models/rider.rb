class Rider < ApplicationRecord
  belongs_to :user, optional: true
  has_many :invitations, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def name = "#{firstname} #{lastname}"

  def registered? = user.present?

  # Legt eine neue Einladung an und macht ältere offene Einladungen ungültig.
  def invite!(by:)
    transaction do
      invitations.pending.update_all(expires_at: Time.current)
      invitations.create!(email: email, invited_by: by)
    end
  end
end
