# frozen_string_literal: true

module Pages
  class MyModules < Base
    set_url '/my-modules'

    elements :cards, class: 'card'

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
