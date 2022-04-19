# Pages namespace to include all pages in the application.
module Pages
  # User page POM.
  class User < SitePrism::Page
    set_url_matcher(%r{/user})

    element :edit, "a[href='/user/edit']"

    section :header, Sections::Header, '.govuk-header'
  end
end
