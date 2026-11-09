module MarkdownHelper
  # Markdown → sicheres HTML. Rohes HTML im Text wird nicht ausgeführt.
  def markdown(text)
    return "".html_safe if text.blank?

    html = Commonmarker.to_html(text.to_s, options: { render: { unsafe: false }, extension: { table: true, autolink: true } })
    html = html.gsub(/<a href="(https?:\/\/[^"]+)"/, '<a href="\1" rel="noopener" target="_blank"')
    tag.div(sanitize(html, tags: %w[h2 h3 h4 p br ul ol li a strong em table thead tbody tr th td blockquote hr code],
                           attributes: %w[href rel target]), class: "prose-ice")
  end
end
