require "test_helper"

class PageTest < ActiveSupport::TestCase
  def build(attrs = {})
    Page.new({ slug: "regeln", title_de: "Regeln", title_en: "Rules", body_de: "Text", body_en: "Text en" }.merge(attrs))
  end

  test "gültige Seite" do
    assert build.valid?
  end

  test "Slug nur Kleinbuchstaben und Bindestriche, nicht reserviert, eindeutig" do
    assert_not build(slug: "Mit Leerzeichen").valid?
    assert_not build(slug: "admin").valid?
    assert_not build(slug: "events").valid?
    build.save!
    assert_not build.valid?
  end

  test "fehlender Text fällt auf die andere Sprache zurück" do
    page = build(body_en: "")
    assert_equal "Text", page.body(:en)
    assert_equal "Rules", page.title(:en)
  end
end

class EventRegistrationUrlTest < ActiveSupport::TestCase
  test "Anmelde-Link nur http(s)" do
    event = events(:summer)
    event.registration_url = "javascript:alert(1)"
    assert_not event.valid?
    event.registration_url = "https://shop.example.com/tickets"
    assert event.valid?
  end
end
