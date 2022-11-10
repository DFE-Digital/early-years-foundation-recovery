# frozen_string_literal: true

module Sections
  class Header < SitePrism::Section
    element :title_link, '.govuk-header__link govuk-header__link--service-name', text: 'GOV.UK Child development training'
    element :logo, '.govuk-header__logotype-text', text: 'Department for Education | '
    element :home, "a[href='/']", text: 'Home'
    element :training_module, "a[href='/modules']", text: 'Training Modules'
    element :sign_in, "a[href='/users/sign-in']", text: 'Sign in'
    element :sign_out, "a[href='/users/sign-out']", text: 'Sign out'
    element :my_account, "a[href='/my-account']", text: 'My account'
  end
end
