import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift,
} from "@floating-ui/dom";
import { Controller } from "@hotwired/stimulus";

const DESKTOP_BREAKPOINT = 769;

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
    const desktopViewport = window.matchMedia(
      `(min-width: ${DESKTOP_BREAKPOINT}px)`,
    );
    this.stopPositioning = autoUpdate(marker, popover, async () => {
      if (!desktopViewport.matches) {
        popover.style.removeProperty("left");
        popover.style.removeProperty("top");
        return;
      }

      const placement = marker.dataset.desktopPlacement || "top";
      const bounds = {
        boundary: this.element.querySelector(".hotspot-image__canvas"),
        padding: 8,
      };

      const { x, y } = await computePosition(marker, popover, {
        placement,
        strategy: "absolute",
        middleware: [offset(12), flip(bounds), shift(bounds)],
      });

      // Ignore results after closing the popover or leaving the desktop layout.
      if (
        this.activeMarker !== marker ||
        popover.hidden ||
        !desktopViewport.matches
      )
        return;

      Object.assign(popover.style, {
        left: `${x}px`,
        top: `${y}px`,
      });
    });
  }

  focusClose(event) {
    if (event.shiftKey || event.currentTarget !== this.activeMarker) return;

    const popover = this.popoverTargets.find(
      (element) =>
        element.id === this.activeMarker.getAttribute("aria-controls"),
    );
    const closeButton = popover?.querySelector(".hotspot-image__close");

    if (!closeButton || popover.hidden) return;

    event.preventDefault();
    closeButton.focus();
  }

  disconnect() {
    this.stopPositioning?.();
    this.stopPositioning = null;
  }
}
