import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["closeButton", "dialog", "trigger"]

  open() {
    this.dialogTarget.showModal()
    this.closeButtonTarget.focus()
  }

  close() {
    this.dialogTarget.close()
  }

  restoreFocus() {
    this.triggerTarget.focus()
  }
}
