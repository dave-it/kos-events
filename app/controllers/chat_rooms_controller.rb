class ChatRoomsController < ApplicationController
  PAGE_SIZE = 100

  layout "app"
  before_action :require_member
  before_action :set_rooms
  before_action :set_room, only: %i[show read]

  def index
  end

  def show
    @messages = @room.messages.includes(user: :rider).order(id: :desc).limit(PAGE_SIZE).reverse
    @room.mark_read!(current_user)
    @unread.delete(@room.id)
  end

  # Wird vom offenen Chatfenster gemeldet, wenn neue Nachrichten gesehen wurden.
  def read
    @room.mark_read!(current_user)
    head :no_content
  end

  private
    def set_rooms
      @rooms = ChatRoom.readable_by(current_user).ordered.to_a
      @unread = ChatRoom.unread_counts(current_user, @rooms)
    end

    # Kanäle ohne Leserecht gibt es für den User nicht (404).
    def set_room
      @room = @rooms.find { |r| r.id == params[:id].to_i || r.id == params[:chat_room_id].to_i } or head :not_found
    end
end
