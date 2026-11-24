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
    this.activePopover = popover;
    this.positionPopover(marker, popover);
    popover.querySelector(".hotspot-image__close").focus({ preventScroll: true });
  }

  keepFocusOnClose(event) {
    event.preventDefault();
  }

  dismiss(event) {
    if (!this.activeMarker) return;

    event.preventDefault();

    const marker = this.activeMarker;
    marker.focus({ preventScroll: true });
    this.reset();
  }

  closeOutside(event) {
    if (!this.activePopover || this.activePopover.contains(event.target)) return;
    // Marker clicks are handled by toggle, including the click that opens a popup.
    if (this.markerTargets.some((marker) => marker.contains(event.target))) return;

    const marker = this.activeMarker;
    this.reset();
    marker.focus({ preventScroll: true });
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
    this.activePopover = null;
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
        rootBoundary: "document",
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

  disconnect() {
    this.stopPositioning?.();
    this.stopPositioning = null;
  }
}
