# Berechnet das Layout eines Heatbaums (links nach rechts) aus Heats und Platzierungen.
# Die Verbindungen werden aus den echten Daten abgeleitet: Ein Fahrer, der in Runde n
# in einem Heat fährt und in Runde n+1 in einem anderen, erzeugt eine Linie zwischen beiden.
class HeatBracket
  CARD_W = 210
  CARD_H = 146
  COL_GAP = 64
  ROW_GAP = 18
  PAD = 8

  Entry = Struct.new(:key, :place, :name, :nation, keyword_init: true) do
    def advanced? = place.present? && place.between?(1, 2)
  end
  Source = Struct.new(:round, :number, :entries, keyword_init: true)
  Node = Struct.new(:round, :number, :entries, :x, :y, :role, keyword_init: true)
  Edge = Struct.new(:from, :to, :kind, keyword_init: true)
  Column = Struct.new(:round, :nodes, :kind, :heat_count, keyword_init: true)

  attr_reader :columns, :edges, :width, :height

  def self.from_heats(heats)
    sources = heats.map do |heat|
      entries = heat.heat_entries.map do |e|
        rider = e.registration.rider
        Entry.new(key: e.registration_id, place: e.place, name: rider.public_name, nation: rider.public_nation)
      end
      Source.new(round: heat.round, number: heat.number, entries: entries)
    end
    new(sources)
  end

  # Kleines Beispiel zur Erklärung des Prinzips (16 Fahrer).
  def self.example
    names = %w[A B C D E F G H I J K L M N O P]
    entry = ->(i, place) { Entry.new(key: i, place: place, name: names[i], nation: nil) }
    round1 = [ [ 0, 7, 8, 15 ], [ 1, 6, 9, 14 ], [ 2, 5, 10, 13 ], [ 3, 4, 11, 12 ] ].each_with_index.map do |ids, n|
      Source.new(round: 1, number: n + 1, entries: ids.each_with_index.map { |id, place| entry.call(id, place + 1) })
    end
    semis = [ [ 0, 1, 7, 6 ], [ 2, 3, 5, 4 ] ].each_with_index.map do |ids, n|
      Source.new(round: 2, number: n + 1, entries: ids.each_with_index.map { |id, place| entry.call(id, place + 1) })
    end
    finals = [ [ 0, 1, 2, 3 ], [ 7, 6, 5, 4 ] ].each_with_index.map do |ids, n|
      Source.new(round: 3, number: n + 1, entries: ids.each_with_index.map { |id, place| entry.call(id, place + 1) })
    end
    new(round1 + semis + finals)
  end

  def initialize(sources)
    rounds = sources.select { |s| s.entries.any? }.group_by(&:round).sort_by(&:first)
    @columns = []
    @edges = []
    layout(rounds)
    @width = [ @columns.size * CARD_W + [ @columns.size - 1, 0 ].max * COL_GAP + PAD * 2, PAD * 2 ].max
    @height = (@columns.flat_map(&:nodes).map { |n| n.y + CARD_H }.max || 0) + PAD
  end

  def empty? = columns.empty?

  private
    def layout(rounds)
      previous = nil
      rounds.each_with_index do |(round, sources), col|
        nodes = sources.sort_by(&:number).map do |s|
          Node.new(round: round, number: s.number, entries: s.entries.sort_by { |e| e.place || 99 },
                   x: PAD + col * (CARD_W + COL_GAP))
        end
        position(nodes, previous)
        @columns << Column.new(round: round, nodes: nodes, heat_count: nodes.size)
        previous = nodes
      end
      label_final_roles
    end

    # Erste Spalte: untereinander. Folgespalten: mittig zwischen den Heats, aus denen die Fahrer kommen.
    def position(nodes, previous)
      step = CARD_H + ROW_GAP
      if previous.nil?
        nodes.each_with_index { |n, i| n.y = PAD + i * step }
        return
      end

      feeders = nodes.to_h { |n| [ n, connect(previous, n) ] }
      wanted = nodes.each_with_index.to_h do |n, i|
        ys = feeders[n].map(&:y)
        [ n, ys.any? ? ys.sum.to_f / ys.size : PAD + i * step ]
      end
      cursor = nil
      nodes.sort_by { |n| [ wanted[n], n.number ] }.each do |n|
        y = wanted[n]
        y = [ y, cursor + step ].max if cursor
        n.y = y.round
        cursor = n.y
      end
    end

    def connect(previous, node)
      keys = node.entries.map(&:key)
      previous.select do |from|
        shared = from.entries.select { |e| keys.include?(e.key) }
        next false if shared.empty?

        kind = shared.any?(&:advanced?) ? :advance : :drop
        @edges << Edge.new(from: from, to: node, kind: kind)
        true
      end
    end

    # In der letzten Spalte: das Heat, das von den Siegern gespeist wird, ist das Finale.
    def label_final_roles
      last = @columns.last or return

      last.kind = :final
      last.nodes.each do |n|
        incoming = @edges.select { |e| e.to.equal?(n) }
        n.role = if incoming.empty? || incoming.any? { |e| e.kind == :advance } then :final else :small_final end
      end
      last.nodes.each { |n| n.role = :final } if last.nodes.size == 1
    end
end
