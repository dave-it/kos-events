require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test "pending findet nur gültige Einladungen" do
    assert_equal invitations(:pending), Invitation.find_pending("pendingtoken1234567890abcdef")
    assert_nil Invitation.find_pending("expiredtoken1234567890abcdef")
    assert_nil Invitation.find_pending("gibtsnicht")
  end

  test "accept! legt User an, verknüpft Rider und markiert Einladung" do
    invitation = invitations(:pending)
    user = invitation.accept!(password: "geheim1234", password_confirmation: "geheim1234")

    assert user.rider_role?
    assert_equal "ben@example.com", user.email_address
    assert_equal user, riders(:ben).reload.user
    assert invitation.reload.accepted?
    assert_nil Invitation.find_pending(invitation.token)
  end

  test "accept! mit zu kurzem Passwort legt nichts an" do
    invitation = invitations(:pending)
    assert_no_difference "User.count" do
      assert_raises(ActiveRecord::RecordInvalid) do
        invitation.accept!(password: "kurz", password_confirmation: "kurz")
      end
    end
    assert_not invitation.reload.accepted?
  end

  test "Rider#invite! macht ältere offene Einladungen ungültig" do
    old = invitations(:pending)
    fresh = riders(:ben).invite!(by: users(:staff))

    assert_nil Invitation.find_pending(old.token)
    assert_equal fresh, Invitation.find_pending(fresh.token)
    assert fresh.expires_at > 13.days.from_now
  end
end
