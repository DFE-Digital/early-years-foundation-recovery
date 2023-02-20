module Pages
  class ModuleOverview < Base
    set_url "/modules{/module_name}"

    element :start_button_module_one, "a[href='/modules/child-development-and-the-eyfs/content-pages/what-to-expect']"

    def start_module(module_name)
      start_button_module_one.click
      ui.content_page
    end
  end
end