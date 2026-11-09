require "test_helper"

class ContentPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Page.create!(slug: "training", title_de: "Training", title_en: "Training", body_de: "## Strecke\n\n**Helm** Pflicht", body_en: "## Track", nav: "header")
    Page.create!(slug: "geheim", title_de: "Geheim", title_en: "Secret", published: false)
  end

  test "zeigt veröffentlichte Seite mit Markdown unter /slug" do
    get "/training"
    assert_response :success
    assert_select "header nav"
    assert_select "h2", "Strecke"
    assert_select "strong", "Helm"
  end

  test "Sprache folgt dem Locale-Parameter" do
    get "/training", params: { locale: "en" }
    assert_response :success
    assert_select "h1", "Training"
    assert_select "h2", "Track"
  end

  test "unveröffentlichte und unbekannte Seiten gibt es nicht" do
    get "/geheim"
    assert_response :not_found
    get "/gibt-es-nicht"
    assert_response :not_found
  end

  test "Navigation zeigt Seiten aus dem Menü" do
    get events_path
    assert_select "nav a[href='/training']"
  end

  test "rohes HTML im Markdown wird nicht ausgeführt" do
    Page.find_by!(slug: "training").update!(body_de: "<script>alert(1)</script>Hallo")
    get "/training"
    assert_select "script", text: /alert/, count: 0
  end

  test "Event-Info und Anmeldelink erscheinen auf der Event-Seite" do
    event = events(:summer)
    event.update!(published: true, info_de: "## Zeitplan\n\nFreitag Training", registration_url: "https://example.com/tickets",
                  registration_deadline: 2.days.from_now)
    get event_path(event)
    assert_select "h2", "Zeitplan"
    assert_select "a[href='https://example.com/tickets']"
  end
end
