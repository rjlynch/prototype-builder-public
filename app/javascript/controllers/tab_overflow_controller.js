import { Controller } from "@hotwired/stimulus"

// Keeps a horizontal list of tabs on a single line. When the tabs don't all
// fit, it hides the overflow and reveals an arrow "tab" on each side that has
// hidden tabs, pointing each at the nearest hidden tab on that side. The arrow
// tabs are server-rendered (hidden by default) and live at the ends of the
// list; hidden tabs collapse out of the way, so a revealed arrow sits flush
// against the visible run. The selected tab (target="selected") is always kept
// visible, so following an arrow — a real navigation that reloads — leaves that
// tab in view with an arrow back the way you came.
//
// Generic: it knows nothing about what the tabs point at. Attach
// data-controller="tab-overflow" to the wrapper, target="list" to the <ul>,
// target="selected" to the current <li>, and target="previous"/"next" to the
// arrow <li>s.
export default class extends Controller {
  static targets = ["list", "selected", "previous", "next"]

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
    if (lo > 0) this.showArrow(this.previousTarget, tabs[lo - 1])
    if (hi < last) this.showArrow(this.nextTarget, tabs[hi + 1])
  }

  // Reverse a previous run: re-hide the arrows, show every tab again.
  reset() {
    this.previousTarget.hidden = true
    this.nextTarget.hidden = true
    this.tabs.forEach((tab) => (tab.hidden = false))
  }

  get tabs() {
    return Array.from(
      this.listTarget.querySelectorAll(
        ":scope > li:not(.app-page-tabs__overflow)"
      )
    )
  }

  // Point an arrow at the nearest hidden tab's destination and reveal it.
  showArrow(arrow, target) {
    const destination = target.querySelector("a[href]")
    if (!destination) return

    arrow.querySelector("a").href = destination.href
    arrow.hidden = false
  }

  // Width of an arrow tab, measured on the real (briefly shown) element.
  measureArrow() {
    this.previousTarget.hidden = false
    const width = this.outerWidth(this.previousTarget)
    this.previousTarget.hidden = true
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
