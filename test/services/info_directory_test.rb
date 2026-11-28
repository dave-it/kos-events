require "test_helper"

class InfoDirectoryTest < ActiveSupport::TestCase
  setup do
    @event = events(:summer)
    @event.info_de = "## Kosten\n\nViel.\n\n## Häufige Fragen\n\n### Wo parken?\n\nAm Track.\n\n### Leer\n"
  end

  test "Event: ## wird Thema, ### wird Eintrag" do
    topics = InfoDirectory.new(event: @event, pages: [], locale: :de).topics

    assert_equal [ "Das Wichtigste", "Häufige Fragen" ], topics.map(&:title)
    assert_equal [ "Kosten" ], topics.first.items.map(&:title)
    assert_equal [ "Wo parken?" ], topics.last.items.map(&:title)
    assert_equal "Am Track.", topics.last.items.first.body
  end

  test "Seiten: ein Thema je Seite, Rechtliches bleibt draußen" do
    page = Page.new(slug: "training", title_de: "Training", title_en: "Training", body_de: "Einleitung\n\n## Zeiten\n\n### Montag\n\nAbends.")
    legal = Page.new(slug: "impressum", title_de: "Impressum", title_en: "Imprint", body_de: "x")
    topics = InfoDirectory.new(event: nil, pages: [ page, legal ], locale: :de).topics

    assert_equal [ "Training" ], topics.map(&:title)
    assert_equal [ "Überblick", "Montag" ], topics.first.items.map(&:title)
    assert_equal "Zeiten", topics.first.items.last.group
  end
end
