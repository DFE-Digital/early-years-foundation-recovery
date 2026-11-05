import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift,
} from "@floating-ui/dom";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fallback", "marker", "popover", "descriptions"];

  connect() {
    this.fallbackTargets.forEach((link) => {
      link.hidden = true;
    });

    this.markerTargets.forEach((button) => {
      button.hidden = false;
    });

    this.descriptionsTarget.hidden = true;
    this.reset();
  }

  toggle(event) {
    const marker = event.currentTarget;
    const wasOpen = marker.getAttribute("aria-expanded") === "true";

    this.reset();

    if (wasOpen) return;

    const popoverId = marker.getAttribute("aria-controls");
    const popover = this.popoverTargets.find(
      (element) => element.id === popoverId,
    );

    if (!popover) return;

    marker.setAttribute("aria-expanded", "true");
    popover.hidden = false;
    this.activeMarker = marker;
    this.positionPopover(marker, popover);
  }

  dismiss(event) {
    if (!this.activeMarker) return;

    event.preventDefault();

    const marker = this.activeMarker;
    marker.focus({ preventScroll: true });
    this.reset();
  }

  closeOutside(event) {
    if (this.element.contains(event.target)) return;

    this.reset();
  }

  reset() {
    this.stopPositioning?.();
    this.stopPositioning = null;

    this.markerTargets.forEach((marker) => {
      marker.setAttribute("aria-expanded", "false");
    });

    this.popoverTargets.forEach((popover) => {
      popover.hidden = true;
    });

    this.activeMarker = null;
  }

  positionPopover(marker, popover) {
    this.stopPositioning = autoUpdate(marker, popover, async () => {
      const { x, y } = await computePosition(marker, popover, {
        placement: "top",
        strategy: "absolute",
        middleware: [offset(12), flip({ padding: 16 }), shift({ padding: 16 })],
      });

      // Ignore a result if this popover was closed while calculating.
      if (this.activeMarker !== marker || popover.hidden) return;

      Object.assign(popover.style, {
        left: `${x}px`,
        top: `${y}px`,
      });
    });
  }

  disconnect() {
    this.stopPositioning?.();
    this.stopPositioning = null;
  }
}
