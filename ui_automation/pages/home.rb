module Pages
  class Home < SitePrism::Page
    set_url Helpers::ConfigHelper.env_config['base_url']
    set_url_matcher %r{/}

    section :header, Sections::Header, '.govuk-header'
  end
end
