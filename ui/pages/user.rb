module Pages
  class User < SitePrism::Page
    set_url_matcher(%r{/user})

    element :edit, "a[href='/user/edit']"

    section :header, Sections::Header, '.govuk-header'
  end
end
