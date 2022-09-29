# frozen_string_literal: true

module Pages
  class Cookies < Base
    set_url '/settings/cookie-policy'

    element :heading, 'h1', text: 'Cookies'
  end
end
