class Invitation < ApplicationRecord
  EXPIRES_IN = 14.days

  belongs_to :rider
  belongs_to :invited_by, class_name: "User"

  has_secure_token :token

  before_validation :set_expiry, on: :create

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  def self.find_pending(token)
    pending.find_by(token: token)
  end

  def accepted? = accepted_at.present?

  # Legt den Fahrer-Account an und verknüpft ihn mit dem Rider.
  def accept!(password:, password_confirmation:)
    transaction do
      user = User.new(email_address: email, password: password,
                      password_confirmation: password_confirmation, role: :rider)
      user.save!
      rider.update!(user: user)
      update!(accepted_at: Time.current)
      user
    end
  end

  private
    def set_expiry
      self.expires_at ||= EXPIRES_IN.from_now
    end
end
