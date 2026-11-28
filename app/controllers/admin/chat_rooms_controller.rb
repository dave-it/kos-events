module Admin
  class ChatRoomsController < ApplicationController
    before_action :require_staff
    before_action :set_room, only: %i[edit update destroy]

    def index
      @rooms = ChatRoom.ordered
    end

    def new
      @room = ChatRoom.new(audience: %w[rider])
    end

    def create
      @room = ChatRoom.new(room_params)
      if @room.save
        redirect_to admin_chat_rooms_path, notice: t("flash.chat_rooms.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @room.update(room_params)
        redirect_to admin_chat_rooms_path, notice: t("flash.chat_rooms.saved")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @room.destroy!
      redirect_to admin_chat_rooms_path, notice: t("flash.chat_rooms.deleted")
    end

    private
      def set_room = @room = ChatRoom.find(params[:id])

      def room_params
        params.expect(chat_room: [ :name_de, :name_en, :description_de, :description_en, :organizers_only, :position, audience: [] ])
      end
  end
end
