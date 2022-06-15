# frozen_string_literal: true

module Sections
  class Footer < SitePrism::Section
    element :terms_and_conditions, "a[href='/terms-and-conditions']", text: 'Terms and conditions'
  end
end
