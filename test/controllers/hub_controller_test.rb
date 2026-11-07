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

  test "Profil ist standardmäßig nicht öffentlich" do
    assert_not riders(:anna).public_profile?
    assert_not_includes Rider.publicly_visible, riders(:anna)
  end

  test "Zustimmung wird mit Zeitpunkt gespeichert und kann widerrufen werden" do
    patch hub_path, params: { rider: { public_profile: "1" } }
    anna = riders(:anna).reload
    assert anna.public_profile?
    assert_not_nil anna.public_profile_consented_at
    assert_includes Rider.publicly_visible, anna

    patch hub_path, params: { rider: { public_profile: "0" } }
    anna.reload
    assert_not anna.public_profile?
    assert_nil anna.public_profile_consented_at
  end
end
