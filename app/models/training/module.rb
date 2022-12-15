module Training
  class Module < ContentfulModel::Base
    self.content_type_id = 'module'

    has_many :pages, class_name: 'Training::Page'

    attr_reader :name
    alias_method :slug, :name

    def module_course_items
      pages
    end
    alias_method :module_items, :module_course_items

    def call_to_action
      yield(:not_started, pages.first)
    end

    # sequence ---------------------------------

    # @return [ModuleItem] page 1
    def interruption_page
      module_items.first
    end

    # @return [ModuleItem] page 2
    def icons_page
      interruption_page.next_item
    end

    # @return [ModuleItem] page 3
    def intro_page
      icons_page.next_item
      # module_items_by_type('module_intro').first
    end

    # Viewing this page determines if the module is "started"
    # @return [ModuleItem] page 5
    def first_content_page
      module_items_by_type('sub_module_intro').first.next_item
    end

    # @return [ModuleItem]
    def summary_intro_page
      module_items_by_type('summary_intro').first
    end

    # @return [ModuleItem]
    def assessment_intro_page
      module_items_by_type('assessment_intro').first
    end

    # @return [ModuleItem]
    def assessment_results_page
      module_items_by_type('assessment_results').first
    end

    # @return [ModuleItem]
    def confidence_intro_page
      module_items_by_type('confidence_intro').first
    end

    # @return [ModuleItem]
    def thankyou_page
      module_items_by_type('thankyou').first
    end

    # @return [ModuleItem]
    def certificate_page
      module_items_by_type('certificate').first
    end

    # @return [ModuleItem]
    def last_page
      module_course_items.last
    end

    def tab_label
      ['Module', id].join(' ')
    end

    def tab_anchor
      tab_label.parameterize
    end

    # @return [String]
    def card_title
      coming_soon = 'Coming soon - ' if draft?
      "#{coming_soon}Module #{id}: #{title}"
    end

    # @return [String]
    def card_anchor
      "#module-#{id}-#{title.downcase.parameterize}"
    end
  
    # @param type [String] text_page, video_page...
    # @return [Array<Training::Page>]
    def module_items_by_type(component)
      Training::Page.where_type(slug, component)
    end

    # @return [Array<ModuleItem>]
    def formative_questions
      module_items_by_type('formative_questionnaire')
    end

    # @return [Array<ModuleItem>]
    def summative_questions
      module_items_by_type('summative_questionnaire')
    end

    # @return [Array<ModuleItem>]
    def confidence_questions
      module_items_by_type('confidence_questionnaire')
    end

    # @return [Array<ModuleItem>]
    def video_pages
      module_items_by_type('video_page')
    end

  end
end