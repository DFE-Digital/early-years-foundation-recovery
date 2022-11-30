module Training
  class Module < ContentfulModel::Base
    self.content_type_id = 'module'

    has_many :pages, class_name: 'Training::Page'

    def module_course_items
      pages 
    end

    def call_to_action
      yield(:not_started, pages.first)
    end

    def tab_label
      ['Module', id].join(' ')
    end

    def tab_anchor
      tab_label.parameterize
    end
  end
end