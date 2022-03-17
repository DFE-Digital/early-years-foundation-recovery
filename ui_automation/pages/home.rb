module Pages
  class Home < SitePrism::Page
    set_url 'http://localhost:3000'

    section :header, Page::Header, '.govuk-header'
  end
end
