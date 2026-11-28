import { Controller } from "@hotwired/stimulus"

// Sofortsuche im Q&A: filtert Einträge, öffnet Treffer und blendet leere Themen aus.
export default class extends Controller {
  static targets = ["query", "item", "topic", "chip", "empty"]

  apply() {
    const words = this.queryTarget.value.toLowerCase().split(/\s+/).filter(Boolean)
    const searching = words.length > 0

    this.itemTargets.forEach((item) => {
      const match = words.every((word) => item.dataset.search.includes(word))
      item.hidden = !match
      item.open = searching && match
    })

    const visible = new Set()
    this.topicTargets.forEach((topic) => {
      const any = this.itemTargets.some((item) => topic.contains(item) && !item.hidden)
      topic.hidden = !any
      if (any) visible.add(topic.dataset.topic)
    })
    this.chipTargets.forEach((chip) => { chip.hidden = !visible.has(chip.dataset.topic) })
    this.emptyTarget.classList.toggle("hidden", visible.size > 0)
  }
}
