class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @rider = invitation.rider
    mail to: invitation.email, subject: "Einladung zum Rider Hub"
  end
end
