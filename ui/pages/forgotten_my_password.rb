# frozen_string_literal: true

module Pages
  class ForgottenMyPassword < Base
    set_url 'users/password/new'

    element :heading, 'h1', text: 'I have forgotten my password'
  end
end
