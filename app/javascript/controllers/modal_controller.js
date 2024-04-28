import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["dialog", "content"];
  connect() {
    if (this.contentTarget.innerText.trim()) this.dialogTarget.showModal();
  }

  open(_event) {
    this.dialogTarget.showModal();
  }

  close(_event) {
    this.dialogTarget.close();
  }
}
