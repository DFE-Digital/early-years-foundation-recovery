# frozen_string_literal: true

module Pages
  class PasswordNew < Base
    set_url 'user/password/new'

    element :heading, 'h1', text: 'I have forgotten my password'
  end
end
