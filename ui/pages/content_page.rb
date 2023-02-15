module Pages
  class ContentPage < Base
    set_url "/modules{/module_name}/content-pages{/page_name}"

    attr_reader :module_name, :page_name

    element :next_button, '.govuk-button', text: 'Next'

    def initialize(*attrs)
      @module_name = attrs[0]&.fetch(:module_name, nil)
      @page_name = attrs[0]&.fetch(:page_name, nil)
    end

    def next_page(notes: false)
      next_button.click
      sleep(2)
      notes ? ui.content_page_with_notes : ui.content_page
    end
  end
end