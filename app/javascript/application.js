import "@hotwired/turbo-rails";
import "@fortawesome/fontawesome-free/js/all";
// import "./controllers";

import { initAll } from "govuk-frontend";

/*
Govuk Accordion component suffers from lag without the turbo listener
*/
document.addEventListener("turbo:load", function() {
  initAll();
})
