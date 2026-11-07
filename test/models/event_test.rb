require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "Ende darf nicht vor Beginn liegen" do
    event = Event.new(name: "X", starts_at: Time.current, ends_at: 1.day.ago)
    assert_not event.valid?
    assert event.errors[:ends_at].any?
  end

  test "published und upcoming" do
    assert_includes Event.published, events(:summer)
    assert_not_includes Event.published, events(:draft)
    assert_includes Event.upcoming, events(:summer)
  end

  test "Kategorie mit Anmeldungen kann nicht gelöscht werden" do
    assert_not categories(:women).destroy
    assert Category.exists?(categories(:women).id)
  end
end
