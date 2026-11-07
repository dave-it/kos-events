require "test_helper"

class RiderTest < ActiveSupport::TestCase
  setup do
    @rider = riders(:anna)
    @rider.update!(nation: "DE", birthday: Date.new(1990, 5, 1))
  end

  test "Erwachsene: Name und Nation immer öffentlich" do
    assert_not @rider.minor?
    assert_equal "Anna Fast", @rider.public_name
    assert_equal "DE", @rider.public_nation
  end

  test "Minderjährige ohne Zustimmung: nur Initialen, keine Nation" do
    @rider.update!(birthday: 15.years.ago.to_date)
    assert @rider.minor?
    assert_equal "A. F.", @rider.public_name
    assert_nil @rider.public_nation
  end

  test "Minderjährige mit Zustimmung: Name und Nation sichtbar" do
    @rider.update!(birthday: 15.years.ago.to_date, public_profile: true)
    assert_equal "Anna Fast", @rider.public_name
    assert_equal "DE", @rider.public_nation
  end

  test "Ohne Geburtstag gilt als minderjährig" do
    @rider.update!(birthday: nil)
    assert @rider.minor?
    assert_equal "A. F.", @rider.public_name
  end

  test "Genau 18 am Geburtstag ist volljährig, am Vortag nicht" do
    on = Date.new(2026, 6, 10)
    @rider.update!(birthday: Date.new(2008, 6, 10))
    assert_not @rider.minor?(on: on)
    assert @rider.minor?(on: on - 1)
  end
end
