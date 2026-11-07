require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "gültiger Token zeigt das Formular" do
    get invitation_path(token: "pendingtoken1234567890abcdef")
    assert_response :success
    assert_select "input[name=password]"
  end

  test "abgelaufener Token wird abgewiesen" do
    get invitation_path(token: "expiredtoken1234567890abcdef")
    assert_redirected_to new_session_path
  end

  test "Annehmen meldet den Fahrer an und leitet in den Hub" do
    patch invitation_path(token: "pendingtoken1234567890abcdef"),
          params: { password: "geheim1234", password_confirmation: "geheim1234" }
    assert_redirected_to hub_path
    follow_redirect!
    assert_response :success
    assert_select "h1", I18n.t("hub.show.title")
  end

  test "falsche Bestätigung zeigt Fehler" do
    patch invitation_path(token: "pendingtoken1234567890abcdef"),
          params: { password: "geheim1234", password_confirmation: "anders1234" }
    assert_response :unprocessable_entity
  end
end
