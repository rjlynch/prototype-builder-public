import { Controller } from "@hotwired/stimulus"

// Sends a link back to the previous entry in the browser's history, so it
// returns to wherever the visitor actually came from. Attach with
// data-controller="back-link" and data-action="back-link#back" on an anchor
// (its href is just a placeholder — navigation is driven entirely here).
export default class extends Controller {
  back(event) {
    event.preventDefault()
    window.history.back()
  }
}
