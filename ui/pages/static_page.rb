# frozen_string_literal: true

module Pages
  class StaticPage < Base
    set_url '{/page_name}'

    element :heading, 'h1'
    element :back_link, '.govuk-back-link', text: 'Back'
  end
end
