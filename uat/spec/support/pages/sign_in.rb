# Pages namespace
module Pages
  class SignIn < SitePrism::Page
    set_url_matcher(%r{users/sign_in})

    section :header, Sections::Header, '.govuk-header'
  end
end
