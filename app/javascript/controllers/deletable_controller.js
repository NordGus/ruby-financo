import { Controller } from "@hotwired/stimulus"

const DATA_HIDDEN_ATTRIBUTE = "data-hidden";

// Connects to data-controller="deletable"
export default class extends Controller {
  static targets = ["confirmation", "trigger"];
  connect() {}

  confirm(_event) {
    this.confirmationTarget.removeAttribute(DATA_HIDDEN_ATTRIBUTE);
    this.triggerTarget.setAttribute(DATA_HIDDEN_ATTRIBUTE, true);
  }

  cancel(_event) {
    this.confirmationTarget.setAttribute(DATA_HIDDEN_ATTRIBUTE, true);
    this.triggerTarget.removeAttribute(DATA_HIDDEN_ATTRIBUTE);
  }
}
