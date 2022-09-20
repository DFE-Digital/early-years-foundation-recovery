# frozen_string_literal: true

module Sections
  class Footer < SitePrism::Section
    element :terms_and_conditions, "a[href='/terms-and-conditions']", text: 'Terms and conditions'
    element :accessibility_statement, "a[href='/accessibility-statement']", text: 'Accessibility statement'
    element :cookie_policy, "a[href='/settings/cookie-policy']", text: 'Cookies'
    element :privacy_policy, "a[href='/privacy-policy']", text: 'Privacy policy'
    element :feedback, "a[href='#FEEDBACK_URL_env_var_missing']", text: 'Feedback'
    element :contact, "a[href='https://forms.office.com/Pages/ResponsePage.aspx?id=yXfS-grGoU2187O4s0qC-ZowRD4JFgJFvn7gnkFCHDBUMDlIRzVDRlZHTDFNRzFDSUw1V1hFTUFHVyQlQCN0PWcu']", text: 'Contact'

  end
end
