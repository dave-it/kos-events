module BracketsHelper
  # Spaltenüberschrift: Finale, Halbfinale, ... nach Anzahl der Heats, sonst "Runde n".
  def bracket_round_name(column, index)
    return t("events.bracket.rounds.final") if column.kind == :final

    key = { 2 => :semi, 4 => :quarter, 8 => :eighth }[column.heat_count]
    key ? t("events.bracket.rounds.#{key}") : t("events.bracket.rounds.number", number: index + 1)
  end

  def bracket_heat_title(node)
    case node.role
    when :small_final then t("events.bracket.small_final")
    when :final then t("events.bracket.final")
    else t("events.bracket.heat", number: node.number)
    end
  end
end
