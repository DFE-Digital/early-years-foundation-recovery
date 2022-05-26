# frozen_string_literal: true

module Sections
  class Footer < SitePrism::Section
    element :terms_and_conditions, "a[href='/static/terms_and_conditions']", text: 'Terms and conditions'
  end
end
