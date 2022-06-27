import "@hotwired/turbo-rails";
// import "./controllers";

import { initAll } from "govuk-frontend";

/*
Govuk Accordion component suffers from lag without the turbo listener
*/
document.addEventListener("turbo:load", function() {
  initAll();
})
