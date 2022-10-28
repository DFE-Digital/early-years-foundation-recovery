import "@hotwired/turbo-rails";
import "@fortawesome/fontawesome-free/js/all";
import TimeoutWarning from "./timeout-warning";
import { initAll } from "govuk-frontend";
import 'govuk-frontend/govuk/vendor/polyfills/Function/prototype/bind'
import 'govuk-frontend/govuk/vendor/polyfills/Element/prototype/classList'

function nodeListForEach (nodes, callback) {
  if (window.NodeList.prototype.forEach) {
    return nodes.forEach(callback)
  }
  for (var i = 0; i < nodes.length; i++) {
    callback.call(window, nodes[i], i, nodes)
  }
}



/*
Govuk Accordion component suffers from lag without the turbo listener
*/
document.addEventListener("turbo:load", function() {
  initAll();
 var $timeoutWarnings = document.querySelectorAll('[data-module="govuk-timeout-warning"]')
  nodeListForEach($timeoutWarnings, function ($timeoutWarning) {
    new TimeoutWarning($timeoutWarning).init()
  });
})
