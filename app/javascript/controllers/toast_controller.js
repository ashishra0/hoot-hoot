import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { sound: { type: String, default: "" } }

  connect() {
    if (this.soundValue) {
      const audio = new Audio(this.soundValue)
      audio.volume = 0.5
      audio.play().catch(() => {})
    }
  }

  dismiss(event) {
    event.preventDefault()
    event.stopPropagation()

    this.element.classList.add("animate-slide-out")
    this.element.addEventListener("animationend", () => this.element.remove())
  }
}
