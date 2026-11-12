require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:summer)
    cat = categories(:pro)
    @heat = Heat.create!(category: cat, round: 1, number: 1)
    riders(:anna).update!(birthday: Date.new(1990, 1, 1))
    reg = Registration.create!(event: @event, category: cat, rider: riders(:anna))
    HeatEntry.create!(heat: @heat, registration: reg, place: 1)
  end

  test "Index zeigt nur veröffentlichte Events" do
    get events_path
    assert_response :success
    assert_select "span", text: "Summer Race"
    assert_select "span", text: "Entwurf Cup", count: 0
  end

  test "Show zeigt den Heatbaum" do
    get event_path(@event)
    assert_response :success
    assert_select "article", /Anna Fast/
    assert_select "nav a", text: "Pro Men"
  end

  test "Listenansicht zeigt den Endstand" do
    get event_path(@event, view: "list")
    assert_response :success
    assert_select "table tbody tr", 1
    assert_select "table tbody tr", /Anna Fast/
    assert_select "a[aria-current=true]", text: "Liste"
  end

  test "Kategorie ohne Heats erscheint nicht im Menü" do
    get event_path(@event)
    assert_select "nav a", text: "Women", count: 0
  end

  test "Entwurf ist nicht öffentlich erreichbar" do
    get event_path(events(:draft))
    assert_response :not_found
  end

  test "Event ohne Ergebnisse zeigt Hinweis" do
    @heat.destroy
    get event_path(@event)
    assert_response :success
    assert_select "p", text: I18n.t("events.show.no_results")
  end

  test "englische Ansicht" do
    get event_path(@event, locale: "en")
    assert_select "h3", text: "Heat tree"
  end

  test "Startseite verlinkt vergangene veröffentlichte Events" do
    @event.update!(starts_at: 10.days.ago)
    get root_path
    assert_select "a[href=?]", event_path(@event)
  end
end
