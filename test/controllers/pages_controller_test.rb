require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "zeigt das nächste veröffentlichte Event mit Countdown" do
    get root_path
    assert_response :success
    assert_select "h2", text: "Summer Race"
    assert_select "[data-controller=countdown]"
  end

  test "Entwürfe erscheinen nicht" do
    events(:summer).update!(published: false)
    get root_path
    assert_select "h2", text: "Summer Race", count: 0
    assert_select "h2", text: "Termine folgen"
  end

  test "Angemeldete sehen Link zu ihrem Bereich" do
    sign_in_as users(:rider_user)
    get root_path
    assert_select "a[href=?]", start_path, text: "Zu meinem Bereich"
  end
end
