# frozen_string_literal: true

module Pages
  class MyModules < Base
    set_url '/my-modules'

#    element :heading, 'h1', text: 'My modules'
#    element :available_module_title, 'h2', text: 'Available modules'
#    element :upcoming_module_title, 'h2', text: 'Upcoming modules'
    elements :cards, class: 'card'

#    element :module_one_link, "a[href='/modules/child-development-and-the-eyfs']"
#    element :module_two_link, "a[href='/modules/brain-development-and-how-children-learn']"
#    element :view_module_two, "a[href='/about-training#module-2-brain-development-and-how-children-learn']", text: 'View more information about this module'
#    element :view_module_three, "a[href='/about-training#module-3-supporting-children-s-personal-social-and-emotional-development']", text: 'View more information about this module'
#    element :success_banner, 'govuk-notification-banner-title', text: 'Success'
#    element :module_three_link, "a[href='/modules/personal-social-and-emotional-development']"

    def module_overview(title:, module_name:)
      wait_until_cards_visible

      card = cards.find(text: title).first
      card.click
      ModuleOverview.new(module_name: module_name).tap do |page|
        wait { page.displayed? }
      end
    end
  end
end