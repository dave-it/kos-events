require "test_helper"

class Admin::RidersControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { sign_in_as users(:staff) }

  test "Index listet Fahrer" do
    get admin_riders_path
    assert_response :success
    assert_select "td", text: "Ben Slow"
  end

  test "Anlegen erstellt Fahrer und verschickt Einladung" do
    assert_difference [ "Rider.count", "Invitation.count" ], 1 do
      assert_enqueued_emails 1 do
        post admin_riders_path, params: { rider: { firstname: "Cleo", lastname: "Run", email: "Cleo@Example.com" } }
      end
    end
    rider = Rider.find_by!(email: "cleo@example.com")
    assert_redirected_to admin_rider_path(rider)
    assert_not rider.registered?
  end

  test "Anlegen mit ungültigen Daten zeigt Fehler" do
    assert_no_difference "Rider.count" do
      post admin_riders_path, params: { rider: { firstname: "", lastname: "X", email: "kaputt" } }
    end
    assert_response :unprocessable_entity
  end

  test "Einladung erneut senden" do
    assert_enqueued_emails 1 do
      post invite_admin_rider_path(riders(:ben))
    end
    assert_redirected_to admin_rider_path(riders(:ben))
  end

  test "Registrierte Fahrer bekommen keine neue Einladung" do
    assert_no_enqueued_emails do
      post invite_admin_rider_path(riders(:anna))
    end
  end
end
