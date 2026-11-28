require "test_helper"

class ChatRoomTest < ActiveSupport::TestCase
  test "Fahrer sehen nur ihre Kanäle, Organisatoren alle" do
    assert_equal [ chat_rooms(:announcements), chat_rooms(:riders) ], ChatRoom.readable_by(users(:rider_user)).ordered.to_a
    assert_equal 3, ChatRoom.readable_by(users(:staff)).count
  end

  test "in Organisator-Kanälen schreiben nur Organisatoren" do
    room = chat_rooms(:announcements)
    assert_not room.writable_by?(users(:rider_user))
    assert room.writable_by?(users(:staff))
    assert chat_rooms(:riders).writable_by?(users(:rider_user))
    assert_not chat_rooms(:helpers).writable_by?(users(:rider_user))
  end

  test "ungelesen zählt nur neue Nachrichten anderer" do
    room = chat_rooms(:riders)
    anna = users(:rider_user)
    room.messages.create!(user: anna, body: "eigene")
    room.messages.create!(user: users(:staff), body: "neu")
    room.messages.create!(user: nil, body: "ehemalig")

    assert_equal({ room.id => 2 }, ChatRoom.unread_counts(anna))
    room.mark_read!(anna)
    assert_empty ChatRoom.unread_counts(anna)
  end

  test "unbekannte Zielgruppe ist ungültig und leere Werte werden entfernt" do
    room = ChatRoom.new(name_de: "X", name_en: "X", audience: [ "", "rider" ])
    assert_equal [ "rider" ], room.audience
    assert room.valid?
    room.audience = [ "admin" ]
    assert_not room.valid?
  end

  test "Fahrer erscheinen im Chat mit abgekürztem Nachnamen" do
    assert_equal "Anna F.", users(:rider_user).display_name
    assert_equal "Staff", users(:staff).display_name
  end
end
