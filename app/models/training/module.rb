require_relative 'content'

module Training
  class Module < Content
    self.content_type_id = 'trainingModule'

    has_many :pages, class_name: 'Training::Page'

    # METHODS TO DEPRECATE --------------------------------------
    def module_course_items
      pages
    end

    def module_items
      pages
    end
    # METHODS TO DEPRECATE --------------------------------------

    # @return [Boolean]
    def draft?
      pages.none?
    end

    # @return [Datetime]
    delegate :published_at, to: :entry

    # NB: Adds additional call to Management API
    #
    # @see ContentfulCourseProgress#debug_summary
    # @return [Contentful::Management::Entry]
    def entry
      @entry ||= to_management
    rescue NoMethodError
      @entry = refetch_management_entry
    end

    # content pages ---------------------------------

    # @return [page] page 1
    def interruption_page
      pages.first
    end

    # @return [page] page 2
    def icons_page
      interruption_page.next_item
    end

    # @return [page] page 3
    def intro_page
      icons_page.next_item
    end

    # Viewing this page determines if the module is "started"
    # @return [Training::Page]
    def first_content_page
      module_items_by_type('sub_module_intro').first.next_item
    end

    # @return [Training::Page]
    def summary_intro_page
      module_items_by_type('summary_intro').first
    end

    # @return [Training::Page]
    def assessment_intro_page
      module_items_by_type('assessment_intro').first
    end

    # @return [Training::Page]
    def assessment_results_page
      module_items_by_type('assessment_results').first
    end

    # @return [Training::Page]
    def confidence_intro_page
      module_items_by_type('confidence_intro').first
    end

    # @return [Training::Page]
    def thankyou_page
      module_items_by_type('thankyou').first
    end

    # @return [Training::Page]
    def certificate_page
      module_items_by_type('certificate').first
    end

    # @return [Training::Page]
    def last_page
      module_course_items.last
    end

    # view decorators ---------------------------------

    def tab_label
      ['Module', position].join(' ')
    end

    def tab_anchor
      tab_label.parameterize
    end

    # @see also accordion on training/modules#index
    # @return [String]
    def card_title
      coming_soon = 'Coming soon - ' if draft?
      "#{coming_soon}Module #{position}: #{title}"
    end

    # @return [String]
    def card_anchor
      "#module-#{id}-#{title.downcase.parameterize}"
    end

    # collections ---------------------------------

    # @param type [String] text_page, video_page...
    # @return [Array<Training::Page, Training::Question, Training::Video>]
    def module_items_by_type(type)
      Training::Page.where_type(name, type)
    end

    # @return [Array<Training::Question>]
    def formative_questions
      module_items_by_type('formative_questionnaire')
    end

    # @return [Array<Training::Question>]
    def summative_questions
      module_items_by_type('summative_questionnaire')
    end

    # @return [Array<Training::Question>]
    def confidence_questions
      module_items_by_type('confidence_questionnaire')
    end

    # @return [Array<Training::Video>]
    def video_pages
      module_items_by_type('video_page')
    end
  end
end
