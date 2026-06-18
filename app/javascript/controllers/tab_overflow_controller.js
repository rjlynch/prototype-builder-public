import { Controller } from "@hotwired/stimulus"

// Keeps a horizontal list of tabs on a single line. When the tabs don't all
// fit, it hides the overflow and inserts an arrow "tab" on each side that has
// hidden tabs; each arrow links to the nearest hidden tab on that side. The
// selected tab (data-tab-overflow-target="selected") is always kept visible,
// so following an arrow — which navigates to a hidden tab and reloads — leaves
// that tab in view with an arrow back the way you came.
//
// Generic: it knows nothing about what the tabs point at. Attach
// data-controller="tab-overflow" to the wrapper, data-tab-overflow-target
// ="list" to the <ul>, mark the current <li> with target="selected", and pass
// the arrows' accessible labels via the previous-/next-label values.
export default class extends Controller {
  static targets = ["list", "selected"]
  static values = { previousLabel: String, nextLabel: String }

  connect() {
    this.refresh = this.refresh.bind(this)
    window.addEventListener("resize", this.refresh)
    // The list may not be laid out yet when streamed in; measure next frame.
    requestAnimationFrame(this.refresh)
  }

  disconnect() {
    window.removeEventListener("resize", this.refresh)
  }

  refresh() {
    this.reset()

    const tabs = this.tabs
    if (tabs.length < 2) return

    const available = this.listTarget.clientWidth
    // Not laid out (e.g. mid-render): try again once there's a width to measure.
    if (available <= 0) {
      requestAnimationFrame(this.refresh)
      return
    }
    const widths = tabs.map((tab) => this.outerWidth(tab))
    const arrow = this.measureArrow()
    const last = tabs.length - 1

    // Grow a contiguous window outward from the selected tab, keeping room for
    // an arrow on whichever side still has tabs left over.
    let lo = this.hasSelectedTarget ? tabs.indexOf(this.selectedTarget) : 0
    let hi = lo
    let used = widths[lo]
    const fits = (extra, hiddenLeft, hiddenRight) =>
      used + extra + (hiddenLeft ? arrow : 0) + (hiddenRight ? arrow : 0) <= available

    let grew = true
    while (grew) {
      grew = false
      if (hi < last && fits(widths[hi + 1], lo > 0, hi + 1 < last)) {
        used += widths[++hi]
        grew = true
      }
      if (lo > 0 && fits(widths[lo - 1], lo - 1 > 0, hi < last)) {
        used += widths[--lo]
        grew = true
      }
    }

    tabs.forEach((tab, index) => {
      if (index < lo || index > hi) tab.hidden = true
    })
    if (lo > 0) this.insertArrow("previous", tabs[lo - 1], tabs[lo])
    if (hi < last) this.insertArrow("next", tabs[hi + 1], tabs[hi].nextSibling)
  }

  // Reverse a previous run: drop the arrows we added, show every tab again.
  reset() {
    this.listTarget
      .querySelectorAll(".app-page-tabs__overflow")
      .forEach((arrow) => arrow.remove())
    this.tabs.forEach((tab) => (tab.hidden = false))
  }

  get tabs() {
    return Array.from(
      this.listTarget.querySelectorAll(
        ":scope > li:not(.app-page-tabs__overflow)"
      )
    )
  }

  insertArrow(direction, target, before) {
    const link = target.querySelector("a[href]")
    if (!link) return

    const item = document.createElement("li")
    item.className = "govuk-tabs__list-item app-page-tabs__overflow"

    const glyph = direction === "previous" ? "&#9664;" : "&#9654;" // ◀ / ▶
    const label =
      direction === "previous" ? this.previousLabelValue : this.nextLabelValue

    const anchor = document.createElement("a")
    anchor.className = "govuk-tabs__tab"
    anchor.href = link.href
    anchor.innerHTML =
      `<span aria-hidden="true">${glyph}</span>` +
      `<span class="govuk-visually-hidden">${label}</span>`

    item.appendChild(anchor)
    this.listTarget.insertBefore(item, before)
  }

  measureArrow() {
    const probe = document.createElement("li")
    probe.className = "govuk-tabs__list-item app-page-tabs__overflow"
    probe.innerHTML = '<a class="govuk-tabs__tab" href="#">&#9654;</a>'
    this.listTarget.appendChild(probe)
    const width = this.outerWidth(probe)
    probe.remove()
    return width
  }

  outerWidth(element) {
    const style = window.getComputedStyle(element)
    return (
      element.offsetWidth +
      parseFloat(style.marginLeft) +
      parseFloat(style.marginRight)
    )
  }
}
