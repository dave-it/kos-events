module AppHelper
  # Linien-Icons (24x24, stroke) für die App-Oberfläche.
  ICONS = {
    home: "M3 11.5 12 4l9 7.5M5.5 10v10h4.5v-6h4v6h4.5V10",
    chat: "M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12Z",
    help: "M9.2 9a2.9 2.9 0 0 1 5.6 1c0 2-2.8 2.4-2.8 4.5M12 18h.01M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Z",
    trophy: "M8 4h8v6a4 4 0 0 1-8 0V4ZM8 6H4.5a3.5 3.5 0 0 0 4 4M16 6h3.5a3.5 3.5 0 0 1-4 4M12 14v4M8 21h8M10 18h4",
    user: "M20 21a8 8 0 0 0-16 0M12 12.5a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9Z",
    users: "M15 20a6 6 0 0 0-12 0M9 11.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7ZM21 20a5 5 0 0 0-5-5M16 4.8a3.5 3.5 0 0 1 0 6.4",
    settings: "M4 7h10M18 7h2M4 17h2M10 17h10M14 4.5v5M6 14.5v5",
    send: "M21 3 10.5 13.5M21 3l-6.5 18-4-7.5L3 9.5 21 3Z",
    search: "M10.5 18a7.5 7.5 0 1 0 0-15 7.5 7.5 0 0 0 0 15ZM16 16l5 5",
    back: "M15 5l-7 7 7 7",
    chevron: "M9 5l7 7-7 7",
    calendar: "M4 6.5h16V20H4V6.5ZM4 10.5h16M8 3.5v5M16 3.5v5",
    flag: "M5 21V4M5 5h13l-2.5 4L18 13H5",
    heart: "M12 20s-8-4.6-8-10.5A4.5 4.5 0 0 1 12 6.7a4.5 4.5 0 0 1 8 2.8C20 15.4 12 20 12 20Z",
    ticket: "M3 8a2 2 0 0 0 2-2h14a2 2 0 0 0 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 0-2 2H5a2 2 0 0 0-2-2v-2a2 2 0 0 0 0-4V8ZM14 6v12",
    eye: "M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7ZM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z",
    download: "M12 3v12M7 11l5 5 5-5M4 20h16",
    lock: "M6 11h12v10H6V11ZM8.5 11V7.5a3.5 3.5 0 0 1 7 0V11",
    menu: "M4 7h16M4 12h16M4 17h16",
    close: "M6 6l12 12M18 6 6 18",
    globe: "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20ZM2 12h20M12 2c3 3 3 17 0 20-3-3-3-17 0-20Z"
  }.freeze

  def app_icon(name, css = "h-6 w-6")
    tag.svg(tag.path(d: ICONS.fetch(name)), viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
            "stroke-width": 1.8, "stroke-linecap": "round", "stroke-linejoin": "round", class: css, "aria-hidden": "true")
  end

  def chat_unread_total
    @chat_unread_total ||= ChatRoom.unread_counts(current_user).values.sum
  end

  # Nachrichtentext: alles escaped, nur http(s)-Adressen werden zu Links.
  def chat_body(text)
    parts = text.split(%r{(https?://[^\s<>"]+[^\s<>".,;:!?)\]])})
    safe_join(parts.each_with_index.map do |part, i|
      i.odd? ? link_to(part, safe_external_url(part), class: "underline break-all", rel: "noopener noreferrer", target: "_blank") : part
    end)
  end
end
