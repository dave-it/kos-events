class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @rider = invitation.rider

    # Sprache des Fahrers verwenden, nicht die des einladenden Teams.
    I18n.with_locale(@rider.locale) do
      mail to: invitation.email, subject: t(".subject")
    end
  end
end
