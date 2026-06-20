import { Controller } from "@hotwired/stimulus"

// Fills the answer field's datalist with the selected question's fixed answers
// (radio/checkbox options), so a branch answer can be picked the way the
// question is. Questions without a fixed set of answers (text inputs) leave the
// list empty, so the field stays free text. The options map is embedded at
// render time; picking a question repopulates the list client-side with no
// round trip.
export default class extends Controller {
  static targets = ["question", "list"]
  static values = { options: Object }

  connect() {
    this.refresh()
  }

  refresh() {
    const answers = this.optionsValue[this.questionTarget.value] || []
    this.listTarget.replaceChildren(
      ...answers.map((answer) => {
        const option = document.createElement("option")
        option.value = answer
        return option
      })
    )
  }
}
