import { Controller } from "@hotwired/stimulus"

// Remembers the open/closed state of the <details> element this controller
// is attached to, keyed by the element's id, so the state survives Turbo
// re-renders and same-tab navigation. Attach with
// data-controller="persisted-details" and
// data-action="toggle->persisted-details#store" on a <details> with an id.
export default class extends Controller {
  connect() {
    const stored = sessionStorage.getItem(this.key)
    if (stored !== null) this.element.open = stored === "open"
  }

  store() {
    sessionStorage.setItem(this.key, this.element.open ? "open" : "closed")
  }

  get key() {
    return `persisted-details:${this.element.id}`
  }
}
