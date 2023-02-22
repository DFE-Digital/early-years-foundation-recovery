module Pages
  class ModuleOverview < Base
    set_url '/modules{/module_name}'

    element :call_to_action, id: 'module_call_to_action'

    def start_module
      wait_until_call_to_action_visible
      call_to_action.click
      ContentPage.new
    end
  end
end
