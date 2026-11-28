class ChatMessage < ApplicationRecord
  MAX_LENGTH = 2000

  belongs_to :chat_room
  belongs_to :user, optional: true

  normalizes :body, with: ->(b) { b.gsub("\r\n", "\n").strip }

  validates :body, presence: true, length: { maximum: MAX_LENGTH }

  after_create_commit -> { broadcast_append_to chat_room, target: "chat_messages" }
  after_destroy_commit -> { broadcast_remove_to chat_room }

  def deletable_by?(other) = other.present? && (other.staff_role? || user_id == other.id)
end
