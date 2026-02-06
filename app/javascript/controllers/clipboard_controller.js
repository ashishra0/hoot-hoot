import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["label"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      if (this.hasLabelTarget) {
        const original = this.labelTarget.textContent
        this.labelTarget.textContent = "Copied!"
        setTimeout(() => { this.labelTarget.textContent = original }, 2000)
      }
    } catch {
      // Fallback for older browsers
      const textarea = document.createElement("textarea")
      textarea.value = this.textValue
      textarea.style.position = "fixed"
      textarea.style.opacity = "0"
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand("copy")
      document.body.removeChild(textarea)
      if (this.hasLabelTarget) {
        const original = this.labelTarget.textContent
        this.labelTarget.textContent = "Copied!"
        setTimeout(() => { this.labelTarget.textContent = original }, 2000)
      }
    }
  }
}
