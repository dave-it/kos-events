require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "zeigt das nächste veröffentlichte Event mit Tagen bis zum Start" do
    events(:summer).update!(starts_at: 30.days.from_now)
    get root_path
    assert_response :success
    assert_select "h2", text: "Summer Race"
    assert_select "p", text: "Noch 30 Tage"
  end

  test "Tage bis zum Start: heute, morgen, Englisch" do
    events(:summer).update!(starts_at: Time.current.change(hour: 23))
    get root_path
    assert_select "p", text: "Heute ist Renntag!"

    events(:summer).update!(starts_at: 1.day.from_now.change(hour: 12))
    get root_path
    assert_select "p", text: "Morgen geht's los!"

    events(:summer).update!(starts_at: 5.days.from_now)
    get root_path(locale: "en")
    assert_select "p", text: "5 days to go"
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
