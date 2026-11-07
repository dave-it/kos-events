require "test_helper"

class Admin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:staff) }

  test "Fahrer haben keinen Zugriff" do
    sign_out
    sign_in_as users(:rider_user)
    get admin_events_path
    assert_response :forbidden
    post admin_event_registrations_path(events(:summer)), params: { registration: { rider_id: riders(:ben).id, category_id: categories(:pro).id } }
    assert_response :forbidden
  end

  test "Index und Show" do
    get admin_events_path
    assert_response :success
    get admin_event_path(events(:summer))
    assert_response :success
    assert_select "h2", /Pro Men/
  end

  test "Event anlegen" do
    assert_difference "Event.count" do
      post admin_events_path, params: { event: { name: "Neu", starts_at: "2027-01-10T10:00" } }
    end
    assert_redirected_to admin_event_path(Event.find_by!(name: "Neu"))
  end

  test "Event ungültig" do
    assert_no_difference "Event.count" do
      post admin_events_path, params: { event: { name: "", starts_at: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "Kategorie anlegen und löschen" do
    assert_difference "events(:summer).categories.count" do
      post admin_event_categories_path(events(:summer)), params: { category: { name: "Juniors", juniors: "1" } }
    end
    cat = events(:summer).categories.find_by!(name: "Juniors")
    delete admin_event_category_path(events(:summer), cat)
    assert_not Category.exists?(cat.id)
  end

  test "Kategorie mit Anmeldungen bleibt erhalten" do
    delete admin_event_category_path(events(:summer), categories(:women))
    assert Category.exists?(categories(:women).id)
  end

  test "Fahrer anmelden, Startnummer setzen, einchecken, entfernen" do
    event = events(:summer)
    assert_difference "event.registrations.count" do
      post admin_event_registrations_path(event), params: { registration: { rider_id: riders(:ben).id, category_id: categories(:pro).id } }
    end
    reg = event.registrations.find_by!(rider: riders(:ben))

    patch admin_event_registration_path(event, reg), params: { registration: { start_number: 12 } }
    assert_equal 12, reg.reload.start_number

    patch check_in_admin_event_registration_path(event, reg)
    assert reg.reload.checked_in?
    patch check_in_admin_event_registration_path(event, reg)
    assert_not reg.reload.checked_in?

    delete admin_event_registration_path(event, reg)
    assert_not Registration.exists?(reg.id)
  end

  test "Doppelte Anmeldung wird abgelehnt" do
    assert_no_difference "Registration.count" do
      post admin_event_registrations_path(events(:summer)), params: { registration: { rider_id: riders(:anna).id, category_id: categories(:pro).id } }
    end
    assert_redirected_to admin_event_path(events(:summer))
  end

  test "Kategorie eines anderen Events wird abgelehnt" do
    assert_no_difference "Registration.count" do
      post admin_event_registrations_path(events(:summer)), params: { registration: { rider_id: riders(:ben).id, category_id: categories(:other_event_cat).id } }
    end
  end
end
