require "test_helper"

class LoginClosedTest < ActionDispatch::IntegrationTest
  setup { Rails.configuration.x.login_open = false }
  teardown { Rails.configuration.x.login_open = true }

  test "Anmeldeseite weist darauf hin, Team kommt hinein" do
    get new_session_path(locale: "de")
    assert_select "[role=status]", /nur für das Team/
    post session_path, params: { email_address: users(:staff).email_address, password: "password123" }
    assert cookies[:session_id].present?
  end

  test "Fahrer, Helfer und Besucher kommen nicht hinein" do
    %i[rider_user helper visitor].each do |name|
      post session_path, params: { email_address: users(name).email_address, password: "password123" }
      assert_redirected_to new_session_path
      assert cookies[:session_id].blank?, name
    end
  end

  test "bestehende Sitzungen von Fahrern gelten nicht mehr" do
    sign_in_as users(:rider_user)
    get hub_path
    assert_redirected_to new_session_path
  end

  test "Einladungen können nicht angenommen werden" do
    assert_no_difference "User.count" do
      patch invitation_path(token: "pendingtoken1234567890abcdef"),
            params: { password: "geheim1234", password_confirmation: "geheim1234" }
    end
    assert_redirected_to new_session_path
  end

  test "Team legt Fahrer an, ohne dass eine Einladung verschickt wird" do
    sign_in_as users(:staff)
    assert_difference "Rider.count", 1 do
      assert_no_difference "Invitation.count" do
        assert_no_enqueued_emails do
          post admin_riders_path, params: { rider: { firstname: "Neu", lastname: "Fahrer", email: "neu@example.com" } }
        end
      end
    end
    rider = Rider.find_by!(email: "neu@example.com")
    assert_no_difference("Invitation.count") { post invite_admin_rider_path(rider) }
    assert_no_difference "Invitation.count" do
      post admin_users_path, params: { invitation: { email: "g@example.com", role: "visitor", locale: "de" } }
    end
  end

  test "Team-Konto mit Fahrerprofil sieht das Fahrerlager samt Verwaltung" do
    riders(:ben).update!(user: users(:staff))
    sign_in_as users(:staff)
    get hub_path
    assert_response :success
    assert_select "nav a[href=?]", admin_events_path
    get profile_hub_path
    assert_response :success
  end
end
