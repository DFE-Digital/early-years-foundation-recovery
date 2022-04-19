# Repeated container within pages
module Sections
  # Header component found in several pages
  class Header < SitePrism::Section
    element :title_link, '.govuk-header__link govuk-header__link--service-name'
    element :logo, '.govuk-header__logotype-text'
    element :home, "a[href='/']"
    element :training_module, "a[href='/modules']"
    element :sign_in, "a[href='/users/sign_in']"
    element :sign_out, "a[href='/users/sign_out']"
    element :profile, "a[href='/user/edit']"
  end
end
