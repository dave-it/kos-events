# Endstand einer Kategorie als Liste, abgeleitet aus dem Heatbaum:
# Finale (1-4), kleines Finale (5-8), danach alle anderen nach der zuletzt erreichten Runde,
# innerhalb einer Runde nach Platz im Heat und Zeitfahren. Der Last Chance Qualifier steht zuletzt.
class CategoryStandings
  Row = Struct.new(:rank, :name, :nation, :stage, :round, :status, :trial_rank, keyword_init: true)

  attr_reader :rows

  def initialize(main, lcq = nil)
    @rows = []
    @seen = {}
    add_bracket(main, lcq: false)
    add_bracket(lcq, lcq: true) if lcq
  end

  def empty? = rows.empty?

  private
    def add_bracket(bracket, lcq:)
      return if bracket.nil? || bracket.empty?

      columns = bracket.columns
      final_column = columns.last
      finals = final_column.nodes.sort_by { |n| [ n.role == :final ? 0 : 1, n.number ] }
      finals.each do |node|
        stage = lcq ? :lcq : node.role
        node.entries.each { |e| add(e, stage, final_column.round) }
      end

      columns[0...-1].reverse_each do |column|
        entries = column.nodes.flat_map(&:entries).reject { |e| @seen[e.key] }
        entries.sort_by { |e| sort_key(e) }.each { |e| add(e, lcq ? :lcq : :round, column.round) }
      end
    end

    def sort_key(entry)
      [ entry.status ? 1 : 0, entry.place || 99, entry.trial_rank || 999 ]
    end

    def add(entry, stage, round)
      return if @seen[entry.key]

      @seen[entry.key] = true
      @rows << Row.new(rank: @rows.size + 1, name: entry.name, nation: entry.nation, stage: stage,
                       round: round, status: entry.status, trial_rank: entry.trial_rank)
    end
end
