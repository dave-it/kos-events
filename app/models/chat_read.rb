# Lesestand eines Users je Kanal.
class ChatRead < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user
end
