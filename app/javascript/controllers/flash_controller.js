import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dismissAfter: { type: Number, default: 4000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
  }

  dismiss() {
    this.element.classList.add("animate-slide-out")
    this.element.addEventListener("animationend", () => this.element.remove())
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}
