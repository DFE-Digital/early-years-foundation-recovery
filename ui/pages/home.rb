module Pages
  class Home < SitePrism::Page
    set_url ENV['BASE_URL']
    set_url_matcher %r{/}

    element :success_banner_title, '#govuk-notification-banner-title'
    section :header, Sections::Header, '.govuk-header'

    # NB: remove once test of "deployed" label is confirmed
  end
end
