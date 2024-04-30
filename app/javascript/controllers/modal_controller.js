import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["dialog"];
  connect() {
    if (this.dialogTarget.innerText.trim() && !this.dialogTarget.open) this.open();
    else this.close();
  }

  open(_event) {
    this.dialogTarget.showModal();
  }

  close(_event) {
    this.dialogTarget.close();
  }
}
