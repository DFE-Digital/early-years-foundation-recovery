# frozen_string_literal: true

module Pages
  class MyModules < Base
    set_url '/my-account/learning-log'
    # set_url '/my-learning'

    element :heading, 'h1', text: 'Your learning log'
   
  end
end
