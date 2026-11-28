class ChatMessagesController < ApplicationController
  before_action :require_member
  before_action :set_room
  rate_limit to: 20, within: 1.minute, only: :create,
             by: -> { Current.user.id },
             with: -> { head :too_many_requests }

  def create
    return head :forbidden unless @room.writable_by?(current_user)

    @message = @room.messages.new(user: current_user, body: params.expect(chat_message: [ :body ])[:body])
    if @message.save
      @room.mark_read!(current_user)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_room_path(@room) }
      end
    else
      redirect_to chat_room_path(@room), alert: @message.errors.full_messages.to_sentence
    end
  end

  def destroy
    message = @room.messages.find(params[:id])
    return head :forbidden unless message.deletable_by?(current_user)

    message.destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(message) }
      format.html { redirect_to chat_room_path(@room) }
    end
  end

  private
    def set_room
      @room = ChatRoom.readable_by(current_user).find(params[:chat_room_id])
    end
end
