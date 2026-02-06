import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  hoot() {
    this.#playHootSound()

    requestAnimationFrame(() => {
      this.element.classList.add("animate-hoot-bounce")
      this.element.classList.remove("animate-pulse-glow")
      // Brief cooldown to prevent spam-clicking, then re-enable
      this.element.style.pointerEvents = "none"
      setTimeout(() => {
        this.element.style.pointerEvents = ""
        this.element.classList.remove("animate-hoot-bounce")
      }, 800)
    })
  }

  #playHootSound() {
    const audio = new Audio("/sounds/hoot.wav")
    audio.volume = 0.5
    audio.play().catch(() => {}) // ignore autoplay restrictions
  }
}
