class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @rider = invitation.rider
    @suffix = invitation.role == "rider" ? "" : "_#{invitation.role}"

    # Sprache des Eingeladenen verwenden, nicht die des einladenden Teams.
    I18n.with_locale(invitation.language) do
      mail to: invitation.email, subject: t(".subject#{@suffix}")
    end
  end
end
