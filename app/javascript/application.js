import '@hotwired/turbo-rails';
import '@fortawesome/fontawesome-free/js/all';

import './controllers';

import { initAll } from 'govuk-frontend';

document.addEventListener('turbo:load', function() {
  initAll();
})
