require "test_helper"

class HubControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:rider_user) }

  test "zeigt eigenes Profil" do
    get hub_path
    assert_response :success
    assert_select "dd", text: "Anna Fast"
  end

  test "Profil aktualisieren" do
    patch hub_path, params: { rider: { nickname: "Flash", nation: "DE" } }
    assert_redirected_to hub_path
    assert_equal "Flash", riders(:anna).reload.nickname
  end

  test "E-Mail und User-Zuordnung sind nicht über Params änderbar" do
    patch hub_path, params: { rider: { email: "hack@example.com", user_id: users(:staff).id } }
    assert_equal "anna@example.com", riders(:anna).reload.email
    assert_equal users(:rider_user), riders(:anna).user
  end
end
