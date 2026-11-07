require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  test "enthält Einladungslink" do
    invitation = invitations(:pending)
    mail = InvitationMailer.invite(invitation)
    assert_equal [ "ben@example.com" ], mail.to
    assert_match "/invitations/#{invitation.token}", mail.text_part.body.to_s
  end
end
