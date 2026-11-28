require "test_helper"

class ChatStreamsChannelTest < ActionCable::Channel::TestCase
  def signed(room) = Turbo::StreamsChannel.signed_stream_name(room)

  test "berechtigte User abonnieren den Kanal" do
    stub_connection current_user: users(:rider_user)
    subscribe signed_stream_name: signed(chat_rooms(:riders))
    assert subscription.confirmed?
  end

  test "ohne Leserecht oder mit gefälschtem Namen wird abgelehnt" do
    stub_connection current_user: users(:rider_user)
    subscribe signed_stream_name: signed(chat_rooms(:helpers))
    assert subscription.rejected?

    subscribe signed_stream_name: "gefaelscht"
    assert subscription.rejected?
  end
end
