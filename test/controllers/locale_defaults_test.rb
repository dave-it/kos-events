require "test_helper"

class LocaleDefaultsTest < ActionDispatch::IntegrationTest
  GERMAN = { "Accept-Language" => "de-AT,de;q=0.9" }.freeze

  test "neue Fahrer sind auf Englisch eingestellt" do
    assert_equal "en", Rider.new.locale
  end

  test "Anmeldung ist auch bei deutschem Browser zuerst Englisch und bleibt umschaltbar" do
    get new_session_path, headers: GERMAN
    assert_select "html[lang=en]"
    patch locale_path("de")
    get new_session_path, headers: GERMAN
    assert_select "html[lang=de]"
  end

  test "Fahrer sieht seine Profilsprache, die Wahl wird gespeichert" do
    riders(:anna).update!(locale: "en")
    sign_in_as users(:rider_user)
    get hub_path, headers: GERMAN
    assert_select "html[lang=en]"

    patch locale_path("de")
    assert_equal "de", riders(:anna).reload.locale
    get hub_path
    assert_select "html[lang=de]"
  end

  test "öffentliche Webseite richtet sich weiter nach dem Browser" do
    get root_path, headers: GERMAN
    assert_select "html[lang=de]"
  end
end
