# Pages namespace to include all pages in the application.
module Pages
  # Privacy Policy page, POM.
  class PrivacyPolicy < SitePrism::Page
    set_url ENV['PRIVACY_URL']
    set_url_matcher %r{static/privacy_policy}
    
    section :header, Sections::Header, '.govuk-header'
  end
end
