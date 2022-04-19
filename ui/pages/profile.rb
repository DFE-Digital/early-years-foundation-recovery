# Pages namespace to include all pages in the application.
module Pages
  # Profile page POM.
  class Profile < SitePrism::Page
    set_url_matcher(%r{/user/edit})

    element :first_name, '#user-first-name-field'
    element :last_name, '#user-last-name-field'
    element :post_code, '#user-postcode-field'
    element :ofsted_number, '#user-ofsted-number-field'
    element :update_button, 'button.govuk-button'

    section :header, Sections::Header, '.govuk-header'
  end
end
