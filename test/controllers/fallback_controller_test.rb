require "test_helper"

class FallbackControllerTest < ActionDispatch::IntegrationTest
  test "alte Seiten werden auf die neuen weitergeleitet" do
    get "/art-hotel-spielberg/"
    assert_redirected_to "/hotel"
    assert_response :moved_permanently

    get "/prices"
    assert_redirected_to "/preise?locale=en"
    get "/en/cookie-policy-eu"
    assert_redirected_to "/cookies?locale=en"
    get "/en/home"
    assert_redirected_to "/?locale=en"
    get "/en"
    assert_redirected_to "/?locale=en"
  end

  test "alte Rennseiten führen zum nächsten Event, sonst zur Eventliste" do
    event = events(:summer)
    event.update!(starts_at: 3.weeks.from_now, ends_at: nil, published: true)
    get "/winterleiten_27"
    assert_redirected_to event_path(Event.published.upcoming.first)
    assert_response :found

    Event.update_all(published: false)
    get "/en/race-2027"
    assert_redirected_to "/events?locale=en"
  end

  test "veröffentlichte Seiten haben Vorrang, /en davor schaltet auf Englisch" do
    Page.create!(slug: "training", title_de: "Training", title_en: "Training", body_de: "Hallo")
    get "/training"
    assert_response :success
    get "/en/training"
    assert_redirected_to "/training?locale=en"
  end

  test "unbekannte Adressen zeigen die Umbau-Seite mit Status 404" do
    [ "/newsletter", "/shopping", "/gibt/es/nicht", "/en/nope" ].each do |path|
      get path
      assert_response :not_found, path
      assert_select "h1", "Wir sind im Umbau"
      assert_select "meta[name=robots][content=noindex]"
      assert_select "header nav"
    end
  end

  test "Umbau-Seite folgt der Sprache, auch bei fehlenden Datensätzen" do
    get "/nope", params: { locale: "en" }
    assert_select "h1", "Under construction"

    get event_path(999_999, locale: "en")
    assert_response :not_found
    assert_select "h1", "Under construction"
  end

  test "andere Formate bekommen keine HTML-Seite" do
    get "/wp-login.php"
    assert_response :not_found
    assert_select "h1", text: "Wir sind im Umbau", count: 0
  end

  test "Cookie-Hinweis steht auf Webseite und Login, nicht in der App" do
    get root_path
    assert_select "[data-controller=notice] a[href='/cookies']"
    get new_session_path
    assert_select "[data-controller=notice]"
    sign_in_as users(:rider_user)
    get hub_path
    assert_select "[data-controller=notice]", 0
  end
end
