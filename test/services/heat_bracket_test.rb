require "test_helper"

class HeatBracketTest < ActiveSupport::TestCase
  test "Beispielbaum hat Spalten, Verbindungen und Finalrollen" do
    bracket = HeatBracket.example

    assert_equal [ 4, 2, 2 ], bracket.columns.map(&:heat_count)
    assert_equal :final, bracket.columns.last.kind
    assert_equal %i[final small_final], bracket.columns.last.nodes.map(&:role)
    assert_equal 4 + 4, bracket.edges.size, "4 Linien in die Halbfinals, 4 in Finale und kleines Finale"
    assert_equal 2, bracket.edges.count { |e| e.kind == :drop }
  end

  test "Folge-Heats stehen mittig zwischen ihren Zubringern" do
    bracket = HeatBracket.example
    first, second = bracket.columns[0].nodes.first(2)
    semi = bracket.columns[1].nodes.first
    assert_equal ((first.y + second.y) / 2.0).round, semi.y
  end

  test "Heats ohne Platzierungen werden nicht dargestellt" do
    empty = HeatBracket::Source.new(round: 0, number: 1, entries: [])
    entry = HeatBracket::Entry.new(key: 1, place: 1, name: "A", nation: nil)
    bracket = HeatBracket.new([ empty, HeatBracket::Source.new(round: 1, number: 1, entries: [ entry ]) ])
    assert_equal [ 1 ], bracket.columns.map(&:round)
  end

  test "leere Eingabe ergibt leeren Baum" do
    bracket = HeatBracket.new([])
    assert bracket.empty?
    assert_equal 0, bracket.edges.size
  end

  test "einzelnes Finale hat keine Verbindungen und ist Finale" do
    entry = HeatBracket::Entry.new(key: 1, place: 1, name: "A", nation: nil)
    bracket = HeatBracket.new([ HeatBracket::Source.new(round: 1, number: 1, entries: [ entry ]) ])
    assert_equal :final, bracket.columns.first.nodes.first.role
    assert_empty bracket.edges
  end

  test "aus echten Heats: Namen folgen der Datenschutzregel" do
    event = events(:summer)
    cat = categories(:pro)
    adult = riders(:anna).tap { |r| r.update!(birthday: Date.new(1990, 1, 1), nation: "AUT") }
    minor = riders(:ben).tap { |r| r.update!(birthday: 14.years.ago.to_date, nation: "GER") }
    heat = Heat.create!(category: cat, round: 1, number: 1)
    [ adult, minor ].each_with_index do |rider, i|
      reg = Registration.create!(event: event, category: cat, rider: rider)
      HeatEntry.create!(heat: heat, registration: reg, place: i + 1)
    end

    entries = cat.brackets[:main].columns.first.nodes.first.entries
    assert_equal [ "Anna Fast", "B. S." ], entries.map(&:name)
    assert_equal [ "AUT", nil ], entries.map(&:nation)
  end
end
