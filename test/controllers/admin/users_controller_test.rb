require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "Staff lädt Besucher ein und bekommt den Link angezeigt" do
    sign_in_as users(:staff)
    assert_difference "Invitation.count", 1 do
      post admin_users_path, params: { invitation: { email: "neu@example.com", role: "visitor", locale: "en" } }
    end
    assert_redirected_to admin_users_path
    invitation = Invitation.find_by!(email: "neu@example.com")
    assert_equal "visitor", invitation.role
    assert_nil invitation.rider
    follow_redirect!
    assert_match invitation.token, response.body
  end

  test "Fahrer-Rolle kann hier nicht vergeben werden" do
    sign_in_as users(:staff)
    assert_no_difference "Invitation.count" do
      post admin_users_path, params: { invitation: { email: "x@example.com", role: "rider", locale: "de" } }
    end
    assert_response :unprocessable_entity
  end

  test "Staff kann Zugang entziehen, aber nicht sich selbst" do
    sign_in_as users(:staff)
    assert_difference "User.count", -1 do
      delete admin_user_path(users(:visitor))
    end
    assert_no_difference "User.count" do
      delete admin_user_path(users(:staff))
    end
  end

  test "Besucher und Fahrer haben keinen Zugriff" do
    [ :visitor, :rider_user ].each do |u|
      sign_in_as users(u)
      get admin_users_path
      assert_response :forbidden
      sign_out
    end
  end
end
