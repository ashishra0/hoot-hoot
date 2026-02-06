import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { mood: String }

  connect() {
    this.isAnimating = false
  }

  hoot(event) {
    event.preventDefault()

    if (this.isAnimating) return
    this.isAnimating = true

    // Play hoot sound
    const audio = new Audio("/sounds/hoot.wav")
    audio.volume = 0.5
    audio.play().catch(() => {})

    // Squish animation
    this.element.classList.add("owl-hooting")

    // Submit the hidden form
    const form = document.getElementById("hoot-form")
    if (form) form.requestSubmit()

    // Re-enable after animation
    setTimeout(() => {
      this.element.classList.remove("owl-hooting")
      this.isAnimating = false
    }, 700)
  }
}
