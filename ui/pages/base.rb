# frozen_string_literal: true

module Pages
  class Base < SitePrism::Page
    def self.set_url(path)
      super(ENV['BASE_URL'] + path)
    end

    section :header, Sections::Header, 'header'
    section :footer, Sections::Footer, 'footer'
  end
end
