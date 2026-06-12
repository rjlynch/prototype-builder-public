import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "label" ]
  static values = {
    text: String,
    successLabel: { type: String, default: "Copied" },
    resetDelay: { type: Number, default: 2000 },
  }

  async copy() {
    await this.writeText(this.textValue)
    this.showSuccess()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  async writeText(text) {
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(text)
        return
      } catch {
        this.copyFromTemporaryInput(text)
        return
      }
    }

    this.copyFromTemporaryInput(text)
  }

  copyFromTemporaryInput(text) {
    const input = document.createElement("textarea")
    input.value = text
    input.setAttribute("readonly", "")
    input.style.position = "fixed"
    input.style.top = "-9999px"
    document.body.appendChild(input)
    input.select()
    document.execCommand("copy")
    input.remove()
  }

  showSuccess() {
    const originalLabel = this.labelTarget.textContent
    this.labelTarget.textContent = this.successLabelValue

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.labelTarget.textContent = originalLabel
    }, this.resetDelayValue)
  }
}
