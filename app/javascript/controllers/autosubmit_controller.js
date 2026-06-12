import { Controller } from "@hotwired/stimulus"

// Submits the form this controller is attached to, debounced. Attach with
// data-controller="autosubmit" on a form and
// data-action="input->autosubmit#submit" on its fields.
export default class extends Controller {
  static targets = [ "status" ]
  static values = {
    delay: { type: Number, default: 300 },
    statusDuration: { type: Number, default: 2000 },
  }

  submit() {
    clearTimeout(this.timeout)
    this.hideStatus()
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  saved(event) {
    if (!event.detail.success || !this.hasStatusTarget) return

    this.statusTarget.hidden = false

    clearTimeout(this.statusTimeout)
    this.statusTimeout = setTimeout(() => this.hideStatus(), this.statusDurationValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
    clearTimeout(this.statusTimeout)
  }

  hideStatus() {
    if (!this.hasStatusTarget) return

    this.statusTarget.hidden = true
  }
}
