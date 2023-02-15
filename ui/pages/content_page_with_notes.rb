module Pages
  class ContentPageWithNotes < Base
    set_url "/modules{/module_name}/content-pages{/page_name}"

    element :save_and_continue_button, 'input[type="submit"]'

    def next_page(notes: false, question: false)
      save_and_continue_button.click
      sleep(2)
      ui.question_page
    end
  end
end