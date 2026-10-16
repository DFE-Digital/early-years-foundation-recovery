import "@fortawesome/fontawesome-free/js/all";
import "@hotwired/turbo-rails";

import "./controllers";

import { initAll } from "govuk-frontend";

const initialisedBodies = new WeakSet();

function initialiseGovukFrontend() {
  const body = document.body;
  if (initialisedBodies.has(body)) return;

  body.classList.add("js-enabled", "govuk-frontend-supported");
  initAll();
  initialisedBodies.add(body);
}

document.addEventListener("turbo:load", initialiseGovukFrontend);
document.addEventListener("turbo:render", initialiseGovukFrontend);
