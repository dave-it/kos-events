import { Controller } from "@hotwired/stimulus"

// Cookie-Hinweis: einmal anzeigen, bis er geschlossen wurde.
const KEY = "cookie-hinweis"

export default class extends Controller {
  connect() {
    this.element.classList.toggle("hidden", this.read() === "gesehen")
  }

  dismiss() {
    try { localStorage.setItem(KEY, "gesehen") } catch { /* z. B. privates Fenster */ }
    this.element.classList.add("hidden")
  }

  read() {
    try { return localStorage.getItem(KEY) } catch { return null }
  }
}
