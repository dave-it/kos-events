# Chat-Kanal zur Koordination. Wer ihn sieht, steht in +audience+; Organisatoren (staff)
# sehen und beschreiben jeden Kanal. Bei +organizers_only+ liest die Zielgruppe nur mit.
class ChatRoom < ApplicationRecord
  AUDIENCES = %w[rider helper visitor].freeze

  has_many :messages, class_name: "ChatMessage", dependent: :delete_all
  has_many :reads, class_name: "ChatRead", dependent: :delete_all

  normalizes :audience, with: ->(roles) { Array(roles).compact_blank.uniq }

  validates :name_de, :name_en, presence: true, length: { maximum: 60 }
  validates :name_de, uniqueness: true
  validate :audience_known

  scope :ordered, -> { order(:position, :name_de) }

  def self.readable_by(user)
    return all if user.staff_role?

    where("? = ANY(audience)", user.role)
  end

  def readable_by?(user) = user.present? && (user.staff_role? || audience.include?(user.role))

  def writable_by?(user) = readable_by?(user) && (user.staff_role? || !organizers_only?)

  def name(locale = I18n.locale) = locale.to_s == "de" ? name_de : name_en

  def description(locale = I18n.locale)
    locale.to_s == "de" ? description_de.presence || description_en : description_en.presence || description_de
  end

  # { room_id => Anzahl ungelesener Nachrichten anderer } für die angegebenen Kanäle.
  def self.unread_counts(user, rooms = readable_by(user))
    ChatMessage.where(chat_room_id: rooms.map(&:id))
               .where("chat_messages.user_id IS DISTINCT FROM ?", user.id)
               .joins(sanitize_sql_array([
                 "LEFT JOIN chat_reads ON chat_reads.chat_room_id = chat_messages.chat_room_id AND chat_reads.user_id = ?", user.id
               ]))
               .where("chat_messages.id > COALESCE(chat_reads.last_read_message_id, 0)")
               .group(:chat_room_id).count
  end

  def mark_read!(user)
    last_id = messages.maximum(:id) or return

    ChatRead.upsert({ chat_room_id: id, user_id: user.id, last_read_message_id: last_id },
                    unique_by: %i[chat_room_id user_id])
  end

  private
    def audience_known
      errors.add(:audience, :inclusion) if (audience - AUDIENCES).any?
    end
end
