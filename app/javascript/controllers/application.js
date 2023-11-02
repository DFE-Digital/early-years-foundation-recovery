import { Application } from "@hotwired/stimulus"
import Reveal from 'stimulus-reveal-controller'

const application = Application.start()

application.register('reveal', Reveal)

application.debug = true
window.Stimulus = application
export { application }