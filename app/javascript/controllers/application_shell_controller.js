import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["accountButton", "accountMenu", "accountMenuDebugDialog", "navigationButton", "shell"]

  connect() {
    this.navigationOpen = false
    this.element.dataset.applicationShellReady = "true"
  }

  toggleNavigation() {
    this.navigationOpen = !this.navigationOpen
    this.shellTarget.classList.toggle("navigation-open", this.navigationOpen)
    this.navigationButtonTarget.setAttribute("aria-expanded", this.navigationOpen)
    this.navigationButtonTarget.setAttribute("aria-label", this.navigationOpen ? "Menu: close navigation" : "Menu: open navigation")
  }

  toggleAccountMenu(event) {
    event.stopPropagation()
    const isOpen = this.accountMenuTarget.hidden

    this.accountMenuTarget.hidden = !isOpen
    this.accountButtonTarget.setAttribute("aria-expanded", isOpen)
    if (this.hasAccountMenuDebugDialogTarget) this.accountMenuDebugDialogTarget.showModal()

    if (isOpen) this.accountMenuTarget.querySelector("a, button")?.focus()
  }

  closeAccountMenu(event) {
    if (!this.hasAccountMenuTarget || this.accountMenuTarget.hidden || this.accountMenuTarget.contains(event.target) || this.accountButtonTarget.contains(event.target)) return

    this.closeAccountMenuAndRestoreFocus()
  }

  closeWithEscape(event) {
    if (event.key !== "Escape") return

    if (this.hasAccountMenuTarget && !this.accountMenuTarget.hidden) {
      this.closeAccountMenuAndRestoreFocus()
    } else if (this.navigationOpen) {
      this.toggleNavigation()
      this.navigationButtonTarget.focus()
    }
  }

  closeAccountMenuAndRestoreFocus() {
    this.accountMenuTarget.hidden = true
    this.accountButtonTarget.setAttribute("aria-expanded", "false")
    this.accountButtonTarget.focus()
  }
}
