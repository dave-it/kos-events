require "test_helper"

class AccessControlTest < ActionDispatch::IntegrationTest
  test "ohne Login wird auf die Anmeldung umgeleitet" do
    get root_path
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

  test "Root leitet nach Rolle weiter" do
    sign_in_as users(:staff)
    get root_path
    assert_redirected_to admin_riders_path
    sign_out
    sign_in_as users(:rider_user)
    get root_path
    assert_redirected_to hub_path
  end

  test "Registrierung ist nicht öffentlich möglich" do
    get "/users/new"
    assert_response :not_found
    post "/users"
    assert_response :not_found
  end
end
