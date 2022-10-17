import "@hotwired/turbo-rails";
import "@fortawesome/fontawesome-free/js/all";
import accessibleAutocomplete from "accessible-autocomplete";
// import "./controllers";

import { initAll } from "govuk-frontend";

accessibleAutocomplete.enhanceSelectElement({
  selectElement: document.querySelector('.govuk-select')
})

/*
Govuk Accordion component suffers from lag without the turbo listener
*/
document.addEventListener("turbo:load", function() {
  initAll();
})
