# frozen_string_literal: true

module Pages
  class MyLearning < Base
    set_url '/my-modules'
    # set_url '/my-learning'

    element :heading, 'h1', text: 'My modules'
    element :available_module_title, 'h2', text: 'Available modules'
    element :upcoming_module_title, 'h2', text: 'Upcoming modules'
    element :module_one_link, "a[href='/modules/child-development-and-the-eyfs']"
    element :module_two_link, "a[href='/modules/brain-development-and-how-children-learn']"
    element :view_module_two, "a[href='/about-training#module-2-brain-development-and-how-children-learn']", text: 'View more information about this module'
    element :view_module_three, "a[href='/about-training#module-3-supporting-children-s-personal-social-and-emotional-development']", text: 'View more information about this module'
    element :success_banner, 'govuk-notification-banner-title', text: 'Success'
    element :module_three_link, "a[href='/modules/personal-social-and-emotional-development']"
    
    def start_child_development_training
      module_one_link.click
      ui.module_overview
    end
  end
end
