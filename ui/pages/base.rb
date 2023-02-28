# frozen_string_literal: true

module Pages
  class Base < SitePrism::Page
    def self.set_url(path)
      super(ENV['BASE_URL'] + path)
    end

    def initialize(default_params = {})
      @default_params = default_params
      super()
    end

    def wait(*args, &block)
      SitePrism::Waiter.wait_until_true(*args, &block)
    end

    def displayed?(*args)
      expected_mappings = args.last.is_a?(::Hash) ? args.pop : {}
      expected_mappings.merge(default_params)
      super(*args, expected_mappings)
    end

    section :header, Sections::Header, 'header.govuk-header'
    section :footer, Sections::Footer, 'footer.govuk-footer'

  private

    attr_reader :default_params

    def next_page_object(args)
      if args[:question]
        QuestionPage.new(args)
      else
        ContentPage.new(args)
      end
    end
  end
end