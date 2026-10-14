import "@fortawesome/fontawesome-free/js/all";
import "@hotwired/turbo-rails";

import "./controllers";

import { initAll } from "govuk-frontend";

function initialiseGovukFrontend() {
  document.body.classList.add("js-enabled", "govuk-frontend-supported");
  initAll();
}

document.addEventListener("turbo:load", initialiseGovukFrontend);
document.addEventListener("turbo:render", initialiseGovukFrontend);
