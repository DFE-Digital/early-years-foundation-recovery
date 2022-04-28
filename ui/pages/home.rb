module Pages
  class Home < SitePrism::Page
    set_url ENV['BASE_URL']
    set_url_matcher %r{/}

    section :header, Sections::Header, '.govuk-header'
  end
end
