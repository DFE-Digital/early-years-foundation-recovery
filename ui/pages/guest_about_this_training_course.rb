# frozen_string_literal: true

module Pages
  class GuestAboutThisTrainingCourse < Base
    set_url '/about-training'

    element :heading, 'h1', text: 'About this training course'
    element :back_link, '.govuk-back-link', text: 'Back'
    element :sign_in_link, "a[href='/users/sign-in']", text: 'sign in'
    element :show_all_sections, '.govuk-accordion__show-all-text', text: 'Show all sections'
    element :hide_all_sections, '.govuk-accordion__show-all-text', text: 'Hide all sections'
  end
end
