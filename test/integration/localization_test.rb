require "test_helper"

class LocalizationTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "Standardsprache ist Deutsch" do
    get root_path
    assert_select "html[lang=de]"
    assert_select "h1", /schnellsten Sport/
  end

  test "Browser-Sprache Englisch wird erkannt" do
    get root_path, headers: { "Accept-Language" => "en-GB,en;q=0.9" }
    assert_select "html[lang=en]"
    assert_select "h1", /fastest sport/
  end

  test "Unbekannte Browser-Sprache fällt auf Deutsch zurück" do
    get root_path, headers: { "Accept-Language" => "fr-FR" }
    assert_select "html[lang=de]"
  end

  test "Umschalter setzt Cookie und gilt für Folgeseiten" do
    patch locale_path("en")
    assert_response :see_other
    get new_session_path
    assert_select "html[lang=en]"
    assert_select "h1", "Sign in"
  end

  test "Ungültige Sprache wird ignoriert" do
    patch locale_path("xx")
    get root_path
    assert_select "html[lang=de]"
  end

  test "Parameter hat Vorrang vor Cookie" do
    patch locale_path("en")
    get root_path(locale: "de")
    assert_select "html[lang=de]"
  end

  test "Einladung erscheint in der Sprache des Fahrers" do
    riders(:ben).update!(locale: "en")
    get invitation_path(token: "pendingtoken1234567890abcdef")
    assert_select "html[lang=en]"
    assert_select "h1", /Welcome, Ben/
  end

  test "Einladungs-Mail nutzt die Fahrer-Sprache, nicht die des Teams" do
    riders(:ben).update!(locale: "en")
    mail = InvitationMailer.invite(invitations(:pending))
    assert_equal "Invitation to the Paddock", mail.subject
    assert_match "Hello Ben", mail.text_part.body.to_s
    riders(:ben).update!(locale: "de")
    assert_equal "Einladung ins Fahrerlager", InvitationMailer.invite(invitations(:pending).reload).subject
  end

  test "Fahrer kann Sprache im Profil ändern, ungültige Werte werden abgelehnt" do
    sign_in_as users(:rider_user)
    patch hub_path, params: { rider: { locale: "en" } }
    assert_equal "en", riders(:anna).reload.locale
    patch hub_path, params: { rider: { locale: "xx" } }
    assert_response :unprocessable_entity
  end

  test "Alle Übersetzungsschlüssel existieren in Deutsch und Englisch" do
    flatten = lambda do |hash, prefix = nil|
      hash.flat_map do |k, v|
        key = [ prefix, k ].compact.join(".")
        v.is_a?(Hash) ? flatten.call(v, key) : [ key ]
      end
    end
    de = flatten.call(YAML.load_file(Rails.root.join("config/locales/de.yml"))["de"])
    en = flatten.call(YAML.load_file(Rails.root.join("config/locales/en.yml"))["en"])
    assert_empty de - en, "Fehlt in en"
    assert_empty en - de, "Fehlt in de"
  end

  test "Staff-Seiten und Hub rendern in beiden Sprachen ohne fehlende Übersetzungen" do
    %w[de en].each do |loc|
      sign_in_as users(:staff)
      [ admin_events_path, admin_event_path(events(:summer)), new_admin_event_path, edit_admin_event_path(events(:summer)),
        admin_riders_path, new_admin_rider_path, admin_rider_path(riders(:ben)) ].each do |path|
        get path, params: { locale: loc }
        assert_response :success, "#{path} (#{loc})"
        assert_select "html[lang=#{loc}]"
      end
      sign_out
      sign_in_as users(:rider_user)
      [ hub_path, edit_hub_path ].each do |path|
        get path, params: { locale: loc }
        assert_response :success, "#{path} (#{loc})"
      end
      sign_out
    end
  end
end
