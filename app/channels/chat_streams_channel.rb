# Live-Updates eines Chat-Kanals. Zusätzlich zum signierten Stream-Namen wird geprüft,
# ob der angemeldete User den Kanal (noch) lesen darf.
class ChatStreamsChannel < ActionCable::Channel::Base
  extend Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    stream_name = verified_stream_name_from_params
    room = ChatRoom.readable_by(current_user.reload).find { |r| r.to_gid_param == stream_name }

    room ? stream_from(stream_name) : reject
  end
end
