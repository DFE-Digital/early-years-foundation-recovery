# frozen_string_literal: true

module Pages
  class PrivacyPolicy < Base
    set_url '/static/privacy_policy'

    element :heading, 'h1', text: 'Privacy policy'
  end
end
