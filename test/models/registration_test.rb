require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  test "Fahrer kann pro Kategorie nur einmal angemeldet sein" do
    reg = Registration.new(event: events(:summer), category: categories(:women), rider: riders(:anna))
    assert_not reg.valid?
    assert reg.errors[:rider_id].any?
  end

  test "Fahrer kann in mehreren Kategorien desselben Events starten" do
    reg = Registration.new(event: events(:summer), category: categories(:pro), rider: riders(:anna))
    assert reg.valid?
  end

  test "Kategorie muss zum Event gehören" do
    reg = Registration.new(event: events(:summer), category: categories(:other_event_cat), rider: riders(:ben))
    assert_not reg.valid?
    assert reg.errors[:category].any?
  end

  test "Startnummer ist pro Kategorie eindeutig" do
    reg = Registration.new(event: events(:summer), category: categories(:women), rider: riders(:ben), start_number: 7)
    assert_not reg.valid?
    assert reg.errors[:start_number].any?
    reg.start_number = 8
    assert reg.valid?
  end

  test "Dieselbe Startnummer darf in einer anderen Kategorie vergeben sein" do
    reg = Registration.new(event: events(:summer), category: categories(:pro), rider: riders(:ben), start_number: 7)
    assert reg.valid?
  end
end
