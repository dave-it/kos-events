require "test_helper"

class GuestControllerTest < ActionDispatch::IntegrationTest
  test "Besucher sieht den Besucherbereich und wird dorthin geleitet" do
    sign_in_as users(:visitor)
    get start_path
    assert_redirected_to guest_path
    get guest_path
    assert_response :success
  end

  test "andere Rollen und Gäste ohne Login kommen nicht hinein" do
    get guest_path
    assert_redirected_to new_session_path
    sign_in_as users(:staff)
    get guest_path
    assert_response :forbidden
  end

  test "Besucher hat weder Fahrerlager noch Team-Bereich" do
    sign_in_as users(:visitor)
    get hub_path
    assert_response :forbidden
    get admin_events_path
    assert_response :forbidden
  end

  test "Besucher-Einladung legt Besucher an" do
    invitation = Invitation.create!(email: "neu@example.com", role: "visitor", locale: "de", invited_by: users(:staff))
    patch invitation_path(token: invitation.token), params: { password: "geheim1234", password_confirmation: "geheim1234" }
    assert_redirected_to start_path
    assert User.find_by!(email_address: "neu@example.com").visitor_role?
  end
end
