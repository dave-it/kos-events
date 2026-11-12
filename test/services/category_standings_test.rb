require "test_helper"

class CategoryStandingsTest < ActiveSupport::TestCase
  test "Beispielbaum: Finale vor kleinem Finale, danach nach erreichter Runde" do
    standings = CategoryStandings.new(HeatBracket.example)

    assert_equal 16, standings.rows.size
    assert_equal (1..16).to_a, standings.rows.map(&:rank)
    assert_equal %i[final] * 4 + %i[small_final] * 4, standings.rows.first(8).map(&:stage)
    assert standings.rows.drop(8).all? { |r| r.stage == :round }
    assert_equal standings.rows.map(&:name).uniq.size, standings.rows.size, "jeder Fahrer nur einmal"
  end

  test "Status-Fahrer stehen innerhalb ihrer Runde zuletzt" do
    entry = ->(key, place, status = nil) { HeatBracket::Entry.new(key: key, place: place, name: "R#{key}", nation: nil, status: status) }
    r1 = HeatBracket::Source.new(round: 1, number: 1, entries: [ entry.(1, 1), entry.(2, 2), entry.(3, 3), entry.(4, -1, "DNS") ])
    r2 = HeatBracket::Source.new(round: 2, number: 1, entries: [ entry.(1, 1), entry.(2, 2) ])
    standings = CategoryStandings.new(HeatBracket.new([ r1, r2 ]))

    assert_equal %w[R1 R2 R3 R4], standings.rows.map(&:name)
    assert_equal "DNS", standings.rows.last.status
  end

  test "leerer Baum ergibt leere Liste" do
    assert CategoryStandings.new(HeatBracket.new([])).empty?
  end
end
