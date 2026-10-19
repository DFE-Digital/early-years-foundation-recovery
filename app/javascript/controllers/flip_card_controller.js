import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["front", "back", "button"];
  static values = { flipped: Boolean };

  connect() {
    this.element.classList.remove("flip-card--animated");
    this.element.classList.add("flip-card--enhanced");

    this.buttonTargets.forEach((button) => {
      button.hidden = false;
    });

    this.render();
  }

  toggle() {
    this.element.classList.add("flip-card--animated");
    this.flippedValue = !this.flippedValue;

    const activeFace = this.flippedValue ? this.backTarget : this.frontTarget;
    const inactiveFace = this.flippedValue ? this.frontTarget : this.backTarget;

    // Expose the destination before moving focus to it.
    this.setFaceActive(activeFace, true);

    this.element.classList.toggle("is-flipped", this.flippedValue);

    activeFace.focus({ preventScroll: true });

    // Hide the old face after focus has left it.
    this.setFaceActive(inactiveFace, false);
  }

  reset() {
    this.element.classList.remove("flip-card--animated");
    this.flippedValue = false;
    this.render();
  }

  render() {
    this.element.classList.toggle("is-flipped", this.flippedValue);

    this.setFaceActive(this.frontTarget, !this.flippedValue);
    this.setFaceActive(this.backTarget, this.flippedValue);
  }

  setFaceActive(face, active) {
    face.inert = !active;

    if (active) {
      face.removeAttribute("aria-hidden");
    } else {
      face.setAttribute("aria-hidden", "true");
    }
  }
}
