# Baut aus den Markdown-Texten der Webseite (Event-Infos und redaktionelle Seiten) ein
# durchsuchbares Verzeichnis: Themen mit aufklappbaren Einträgen. So gibt es nur eine Quelle:
# Was im Team-Bereich geändert wird, steht auch hier.
#
# Event-Infos: jede "##"-Überschrift ist ein Thema, jede "###"-Überschrift darin ein Eintrag.
# Seiten: jede Seite ist ein Thema, jede Überschrift ein Eintrag.
class InfoDirectory
  Topic = Struct.new(:key, :title, :source, :items, keyword_init: true)
  Item = Struct.new(:title, :group, :body, keyword_init: true)
  Section = Struct.new(:level, :title, :body, keyword_init: true)

  EXCLUDED_PAGES = %w[impressum datenschutz cookies mitglied-werden unterstuetzung].freeze

  def self.sections(markdown)
    sections = [ Section.new(level: 0, title: nil, body: +"") ]
    markdown.to_s.each_line do |line|
      if (heading = line.match(/\A(\#{2,3})[ \t]+(.+?)[ \t]*\#*[ \t]*\n?\z/))
        sections << Section.new(level: heading[1].length, title: heading[2], body: +"")
      else
        sections.last.body << line
      end
    end
    sections.each { |s| s.body = s.body.strip }
  end

  def initialize(event:, pages:, locale: I18n.locale)
    @event = event
    @pages = pages.reject { |p| EXCLUDED_PAGES.include?(p.slug) }
    @locale = locale
  end

  def topics = event_topics + page_topics

  private
    def event_topics
      return [] unless @event

      topics = []
      self.class.sections(@event.info(@locale)).each do |section|
        if section.level == 2
          topics << Topic.new(key: "event-#{topics.size + 1}", title: section.title, source: @event.name, items: [])
          topics.last.items << Item.new(title: section.title, body: section.body) if section.body.present?
        elsif section.level == 3 && topics.any? && section.body.present?
          topics.last.items << Item.new(title: section.title, body: section.body)
        end
      end
      merge_single(topics.reject { |t| t.items.empty? })
    end

    # Abschnitte, die nur aus einer Antwort bestehen (z. B. "Was kostet die Nennung?"),
    # kommen gemeinsam in ein erstes Thema, statt jede Überschrift doppelt zu zeigen.
    def merge_single(topics)
      single, grouped = topics.partition { |t| t.items.size == 1 && t.items.first.title == t.title }
      return grouped if single.empty?

      essentials = Topic.new(key: "event-essentials", title: I18n.t("info.essentials", locale: @locale),
                             source: @event.name, items: single.flat_map(&:items))
      [ essentials, *grouped ]
    end

    def page_topics
      @pages.filter_map do |page|
        group = nil
        items = self.class.sections(page.body(@locale)).filter_map do |section|
          group = section.title if section.level == 2
          next if section.body.blank?

          Item.new(title: section.title || I18n.t("info.overview", locale: @locale),
                   group: (group if section.level == 3), body: section.body)
        end
        Topic.new(key: "page-#{page.slug}", title: page.title(@locale), source: nil, items: items) if items.any?
      end
    end
end
