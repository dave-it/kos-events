# Redaktionelle Seite (Markdown, zweisprachig), bearbeitbar im Team-Bereich.
class Page < ApplicationRecord
  NAVS = %w[header footer none].freeze
  RESERVED_SLUGS = %w[admin events hub session passwords invitations locale start up p rails assets].freeze

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/ },
                   exclusion: { in: RESERVED_SLUGS }
  validates :title_de, :title_en, presence: true
  validates :nav, inclusion: { in: NAVS }

  scope :published, -> { where(published: true) }
  scope :in_nav, ->(place) { published.where(nav: place).order(:position, :slug) }

  def to_param = slug

  def title(locale = I18n.locale) = localized(:title, locale)
  def body(locale = I18n.locale) = localized(:body, locale)

  private
    # Fehlt der Text in der gewünschten Sprache, wird die andere angezeigt.
    def localized(attr, locale)
      primary = public_send("#{attr}_#{locale}")
      primary.presence || public_send("#{attr}_#{locale.to_s == 'de' ? 'en' : 'de'}")
    end
end
