require "test_helper"

class ChatTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:rider_user) }

  test "Kanalliste zeigt nur erlaubte Kanäle" do
    get chat_rooms_path
    assert_response :success
    assert_select "a", /Fahrer-Chat/
    assert_select "a", text: /Helfer/, count: 0
  end

  test "Nachricht senden" do
    assert_difference "ChatMessage.count", 1 do
      post chat_room_messages_path(chat_rooms(:riders)), params: { chat_message: { body: "Hallo!" } }, as: :turbo_stream
    end
    assert_response :success
    assert_match "Hallo!", response.body
  end

  test "HTML in Nachrichten wird nicht ausgeführt, Links werden verlinkt" do
    chat_rooms(:riders).messages.create!(user: users(:staff), body: %(<script>alert(1)</script> https://example.com/a"onmouseover="x))
    get chat_room_path(chat_rooms(:riders))
    assert_response :success
    assert_select ".chat-bubble script", 0
    assert_select ".chat-bubble a[href='https://example.com/a']"
    assert_select ".chat-bubble a[onmouseover]", 0
  end

  test "Fahrer kann nicht in Ankündigungen schreiben" do
    get chat_room_path(chat_rooms(:announcements))
    assert_select "textarea", 0
    assert_no_difference "ChatMessage.count" do
      post chat_room_messages_path(chat_rooms(:announcements)), params: { chat_message: { body: "x" } }
    end
    assert_response :forbidden
  end

  test "fremde Kanäle sind nicht erreichbar" do
    get chat_room_path(chat_rooms(:helpers))
    assert_response :not_found
    post chat_room_messages_path(chat_rooms(:helpers)), params: { chat_message: { body: "x" } }
    assert_response :not_found
    patch read_chat_room_path(chat_rooms(:helpers))
    assert_response :not_found
  end

  test "eigene Nachrichten löschen, fremde nicht; Organisatoren dürfen alles" do
    own = chat_rooms(:riders).messages.create!(user: users(:rider_user), body: "meins")
    other = chat_rooms(:riders).messages.create!(user: users(:staff), body: "deins")

    delete chat_room_message_path(chat_rooms(:riders), other)
    assert_response :forbidden
    assert_difference("ChatMessage.count", -1) { delete chat_room_message_path(chat_rooms(:riders), own) }

    sign_in_as users(:staff)
    assert_difference("ChatMessage.count", -1) { delete chat_room_message_path(chat_rooms(:riders), other) }
  end

  test "Helfer und Besucher haben den App-Bereich noch nicht" do
    [ :helper, :visitor ].each do |name|
      sign_in_as users(name)
      get chat_rooms_path
      assert_response :forbidden
      get info_path
      assert_response :forbidden
      get start_path
      assert_redirected_to guest_path
    end
  end

  test "ohne Login kein Chat" do
    sign_out
    get chat_rooms_path
    assert_redirected_to new_session_path
  end

  test "nur Organisatoren verwalten Kanäle" do
    get admin_chat_rooms_path
    assert_response :forbidden

    sign_in_as users(:staff)
    get admin_chat_rooms_path
    assert_response :success
    get new_admin_chat_room_path
    assert_response :success
    post admin_chat_rooms_path, params: { chat_room: { name_de: "Neu", name_en: "New", audience: [ "", "rider" ], organizers_only: "1" } }
    assert_redirected_to admin_chat_rooms_path
    room = ChatRoom.find_by!(name_de: "Neu")
    assert room.organizers_only?
    get edit_admin_chat_room_path(room)
    assert_response :success
    patch admin_chat_room_path(room), params: { chat_room: { audience: [ "" ] } }
    assert_empty room.reload.audience
    assert_difference("ChatRoom.count", -1) { delete admin_chat_room_path(room) }
  end
end
