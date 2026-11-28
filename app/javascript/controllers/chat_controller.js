import { Controller } from "@hotwired/stimulus"

// Chatfenster: eigene Nachrichten markieren, mitscrollen, Lesestand melden, Eingabe bedienen.
export default class extends Controller {
  static targets = ["scroll", "message", "input", "form"]
  static values = { user: Number, staff: Boolean, readUrl: String, confirm: String }

  connect() {
    this.scrollToEnd()
    this.ready = true
  }

  disconnect() {
    clearTimeout(this.readTimer)
    this.ready = false
  }

  messageTargetConnected(message) {
    const mine = Number(message.dataset.author) === this.userValue
    message.classList.toggle("is-mine", mine)
    if (mine || this.staffValue) message.querySelector("[data-delete]")?.classList.remove("hidden")

    if (!this.ready) return
    if (mine || this.nearEnd(message.offsetHeight)) this.scrollToEnd()
    if (!mine) this.reportRead()
  }

  keydown(event) {
    // Mit Tastatur sendet Enter, Umschalt+Enter macht einen Zeilenumbruch. Am Handy bleibt Enter ein Umbruch.
    if (event.key !== "Enter" || event.shiftKey || event.isComposing || !window.matchMedia("(pointer: fine)").matches) return

    event.preventDefault()
    this.formTarget.requestSubmit()
  }

  sent(event) {
    if (!event.detail.success) return

    this.formTarget.reset()
    this.inputTarget.focus()
    this.scrollToEnd()
  }

  confirmDelete(event) {
    if (!window.confirm(this.confirmValue)) event.preventDefault()
  }

  nearEnd(extra = 0) {
    const el = this.scrollTarget
    return el.scrollHeight - el.scrollTop - el.clientHeight < 120 + extra
  }

  scrollToEnd() {
    requestAnimationFrame(() => { this.scrollTarget.scrollTop = this.scrollTarget.scrollHeight })
  }

  reportRead() {
    clearTimeout(this.readTimer)
    this.readTimer = setTimeout(() => {
      if (document.visibilityState !== "visible") return

      fetch(this.readUrlValue, {
        method: "PATCH",
        headers: { "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content }
      })
    }, 800)
  }
}
