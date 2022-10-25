import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from 'accessible-autocomplete'

// Connects to data-controller="autocomplete"
export default class extends Controller {
  connect() {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: document.querySelector('.govuk-select')
    })
  }
}
