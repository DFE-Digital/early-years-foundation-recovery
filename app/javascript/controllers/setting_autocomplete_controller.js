import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from 'accessible-autocomplete'

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static values = { message: String }

  connect() {
    accessibleAutocomplete.enhanceSelectElement({
      tNoResults: () => this.messageValue,
      selectElement: document.querySelector('#user-setting-type-id-field')
    })
  }
}
