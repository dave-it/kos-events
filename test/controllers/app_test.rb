require "test_helper"

class AppTest < ActionDispatch::IntegrationTest
  test "Login-Seite nennt die drei Zugangsarten" do
    get new_session_path(locale: "de")
    assert_response :success
    assert_select "li", /Fahrer/
    assert_select "li", /Helfer/
    assert_select "li", /Besucher/
    assert_select "link[rel=manifest]"
  end

  test "Manifest und Service Worker sind ohne Login abrufbar" do
    get pwa_manifest_path(format: :json)
    assert_response :success
    manifest = JSON.parse(response.body)
    assert_equal "/launch", manifest["start_url"]
    manifest["icons"].each { |icon| assert Rails.public_path.join(icon["src"].delete_prefix("/")).exist? }

    get "/service-worker.js"
    assert_response :success
    assert_match "offline.html", response.body
  end

  test "App-Start leitet je nach Anmeldung weiter" do
    get launch_path
    assert_redirected_to root_path
    sign_in_as users(:rider_user)
    get launch_path
    assert_redirected_to start_path
  end

  test "Q&A zeigt Inhalte der Webseite" do
    events(:summer).update!(starts_at: 2.weeks.from_now, ends_at: nil, published: true, info_de: "## Häufige Fragen\n\n### Wo parken?\n\nAm Track.")
    sign_in_as users(:rider_user)
    get info_path
    assert_response :success
    assert_select "details summary", /Wo parken\?/
  end

  test "Ergebnisse erscheinen für Mitglieder in der App, sonst öffentlich" do
    get events_path
    assert_select "footer"
    sign_in_as users(:rider_user)
    get events_path
    assert_select "nav[aria-label='App-Navigation']"
    assert_select "footer", 0
  end
end
