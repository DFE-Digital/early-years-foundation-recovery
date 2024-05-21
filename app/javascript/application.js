import '@hotwired/turbo-rails';
import '@fortawesome/fontawesome-free/js/all';

import './controllers';

import { initAll } from "govuk-frontend";

function nodeListForEach (nodes, callback) {
  if (window.NodeList.prototype.forEach) {
    return nodes.forEach(callback)
  }
  for (var i = 0; i < nodes.length; i++) {
    callback.call(window, nodes[i], i, nodes)
  }
}

/*
document.addEventListener('turbo:load', function() {
  initAll();
})
*/
