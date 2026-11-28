# Bringt die Rechtstexte auf bestehenden Installationen auf den neuen Stand und legt
# Cookie-Seite und Start-Kanäle an. Seiten, die im Team-Bereich bearbeitet wurden,
# bleiben unverändert.
class UpdateLegalPagesAndChatRooms < ActiveRecord::Migration[8.1]
  class Page < ActiveRecord::Base; end
  class ChatRoom < ActiveRecord::Base; end

  SLUGS = %w[impressum datenschutz cookies].freeze

  def up
    return if Rails.env.test?

    # Nur auf bereits befüllten Installationen; neue bekommen alles über db:seed.
    return unless Page.exists?

    content("pages.yml").select { |attrs| SLUGS.include?(attrs["slug"]) }.each do |attrs|
      page = Page.find_or_initialize_by(slug: attrs["slug"])
      if page.persisted? && page.updated_at - page.created_at > 1
        say "Seite #{page.slug} wurde bearbeitet und bleibt unverändert"
      else
        page.update!(attrs.reverse_merge("published" => true))
      end
    end

    content("chat_rooms.yml").each { |attrs| ChatRoom.create!(attrs) } unless ChatRoom.exists?
  end

  def down
  end

  private
    def content(file) = YAML.safe_load_file(Rails.root.join("db/content", file))
end
