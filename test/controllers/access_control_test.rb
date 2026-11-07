require "test_helper"

class AccessControlTest < ActionDispatch::IntegrationTest
  test "Landing Page ist öffentlich" do
    get root_path
    assert_response :success
    assert_select "h1", /schnellsten Sport/
  end

  test "ohne Login wird auf die Anmeldung umgeleitet" do
    get start_path
    assert_redirected_to new_session_path
    get hub_path
    assert_redirected_to new_session_path
    get admin_riders_path
    assert_redirected_to new_session_path
  end

  test "Fahrer kommt nicht in den Staff-Bereich" do
    sign_in_as users(:rider_user)
    get admin_riders_path
    assert_response :forbidden
    post invite_admin_rider_path(riders(:ben))
    assert_response :forbidden
  end

  test "Staff hat keinen Rider Hub" do
    sign_in_as users(:staff)
    get hub_path
    assert_response :forbidden
  end

  test "Start leitet nach Rolle weiter" do
    sign_in_as users(:staff)
    get start_path
    assert_redirected_to admin_events_path
    sign_out
    sign_in_as users(:rider_user)
    get start_path
    assert_redirected_to hub_path
  end

  test "Registrierung ist nicht öffentlich möglich" do
    get "/users/new"
    assert_response :not_found
    post "/users"
    assert_response :not_found
  end
end
