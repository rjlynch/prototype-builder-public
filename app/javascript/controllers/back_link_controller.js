import { Controller } from "@hotwired/stimulus"

// Sends a link back to the previous entry in the browser's history, so it
// returns to wherever the visitor actually came from. Falls back to the
// link's own href when there is no history to go back to (e.g. the page was
// opened directly). Attach with data-controller="back-link" and
// data-action="back-link#back" on an anchor.
export default class extends Controller {
  back(event) {
    if (window.history.length > 1) {
      event.preventDefault()
      window.history.back()
    }
  }
}
