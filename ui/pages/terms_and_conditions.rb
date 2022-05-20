# Pages namespace to include all pages in the application.
module Pages
  # Terms and Conditions page, POM.
  class TermsAndConditions < SitePrism::Page
    set_url ENV['TERMS_URL']
    set_url_matcher %r{static/terms_and_conditions}

    section :header, Sections::Header, '.govuk-header'
  end
end
