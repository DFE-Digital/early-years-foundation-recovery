module Pages
  class Home < SitePrism::Page
    set_url ENV.fetch('BASE_URL', 'http://localhost:3000')

    set_url_matcher %r{/}

    section :header, Sections::Header, '.govuk-header'
  end
end
