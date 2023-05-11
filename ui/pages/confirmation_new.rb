# frozen_string_literal: true

module Pages
  class ConfirmationNew < Base
    set_url '/users/confirmation/new'

    element :heading, 'h1', text: 'Resend your confirmation'
  end
end
