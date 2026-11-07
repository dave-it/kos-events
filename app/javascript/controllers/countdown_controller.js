import { Controller } from "@hotwired/stimulus"

// Zählt bis zum Zeitpunkt in data-countdown-to-value (ISO 8601) herunter.
export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"]
  static values = { to: String }

  connect() {
    this.target = new Date(this.toValue).getTime()
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const left = Math.max(0, this.target - Date.now())
    const pad = (n) => String(n).padStart(2, "0")
    this.daysTarget.textContent = Math.floor(left / 86400000)
    this.hoursTarget.textContent = pad(Math.floor(left / 3600000) % 24)
    this.minutesTarget.textContent = pad(Math.floor(left / 60000) % 60)
    this.secondsTarget.textContent = pad(Math.floor(left / 1000) % 60)
    if (left === 0) clearInterval(this.timer)
  }
}
