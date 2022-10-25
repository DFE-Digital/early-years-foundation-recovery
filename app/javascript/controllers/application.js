import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = true
window.Stimulus = application
export { application }