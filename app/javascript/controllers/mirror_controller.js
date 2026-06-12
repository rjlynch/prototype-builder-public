import { Controller } from "@hotwired/stimulus"

// Mirrors a field's value into a display element as the user types. Attach
// data-controller="mirror" to a wrapper, data-mirror-target="source" and
// data-action="input->mirror#refresh" to the field, and
// data-mirror-target="output" to the display element.
export default class extends Controller {
  static targets = ["source", "output"]

  refresh() {
    this.outputTarget.textContent = this.sourceTarget.value
  }
}
