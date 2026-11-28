import { Controller } from "@hotwired/stimulus"

// Passwort ein- und ausblenden.
export default class extends Controller {
  static targets = ["input", "button"]

  toggle() {
    const show = this.inputTarget.type === "password"
    this.inputTarget.type = show ? "text" : "password"
    this.buttonTarget.setAttribute("aria-pressed", show)
  }
}
