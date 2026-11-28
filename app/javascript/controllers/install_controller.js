import { Controller } from "@hotwired/stimulus"

// "App installieren": Button, wenn der Browser es anbietet, sonst Anleitung für iPhone/iPad.
export default class extends Controller {
  static targets = ["button", "ios"]

  connect() {
    this.refresh = this.refresh.bind(this)
    window.addEventListener("app:installable", this.refresh)
    this.refresh()
  }

  disconnect() {
    window.removeEventListener("app:installable", this.refresh)
  }

  refresh() {
    const standalone = window.matchMedia("(display-mode: standalone)").matches || navigator.standalone === true
    const ios = /iphone|ipad|ipod/i.test(navigator.userAgent)
    const installable = Boolean(window.deferredInstall)

    this.element.classList.toggle("hidden", standalone || !(installable || ios))
    this.buttonTarget.classList.toggle("hidden", !installable)
    this.iosTarget.classList.toggle("hidden", installable || !ios)
  }

  async prompt() {
    const event = window.deferredInstall
    if (!event) return

    window.deferredInstall = null
    await event.prompt()
    this.refresh()
  }
}
