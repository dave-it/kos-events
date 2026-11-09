module ApplicationHelper
  # Nur http(s)-Adressen als Link ausgeben (Schutz vor javascript:-URLs aus Redaktionsdaten).
  def safe_external_url(url)
    url.to_s.match?(/\Ahttps?:\/\/\S+\z/) ? url : "#"
  end
end
