import '@hotwired/turbo-rails';
import '@fortawesome/fontawesome-free/js/all';

import './controllers';

import { initAll } from 'govuk-frontend';

document.addEventListener('turbo:load', function() {
  document.body.classList.add('js-enabled', 'govuk-frontend-supported');
  initAll();
})
