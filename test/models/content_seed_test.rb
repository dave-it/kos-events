require "test_helper"

class ContentSeedTest < ActiveSupport::TestCase
  PAGES = YAML.safe_load_file(Rails.root.join("db/content/pages.yml"))

  test "alle Seiten aus den Inhaltsdateien sind gültig und zweisprachig" do
    PAGES.each do |attrs|
      page = Page.new(attrs)
      assert page.valid?, "#{attrs['slug']}: #{page.errors.full_messages}"
      assert page.body_de.present? && page.body_en.present?, attrs["slug"]
    end
    assert_empty %w[impressum datenschutz cookies] - PAGES.map { |p| p["slug"] }
  end

  test "interne Links in den Seiten zeigen auf vorhandene Ziele" do
    known = PAGES.map { |p| "/#{p['slug']}" } + [ "/events" ]
    links = PAGES.flat_map { |p| "#{p['body_de']}#{p['body_en']}".scan(%r{\]\((/[^)\s#?]*)}).flatten }
    assert_empty links.uniq - known
  end

  test "persönliche Inhalte werden aus Protokollen gefiltert" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtered = filter.filter("chat_message" => { "body" => "geheim" }, "rider" => { "birthday" => "2000-01-01", "lastname" => "X" })
    assert_equal "[FILTERED]", filtered.dig("chat_message", "body")
    assert_equal "[FILTERED]", filtered.dig("rider", "birthday")
  end
end
