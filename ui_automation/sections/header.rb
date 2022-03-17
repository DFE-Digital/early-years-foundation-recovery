module Page
  class Header < SitePrism::Section
    element :title_link, ".govuk-header__link govuk-header__link--service-name"
    element :logo, ".govuk-header__logotype-text"
    element :home, "a[href='/']"
    element :training_module, "a[href='/modules']"
    element :sign_in, "a[href='/users/sign_in']"
  end
end
