module Training
  class Content < ContentfulModel::Base

    include ::Management
    include ::Pagination
    include ::ContentTypes

    # @return [Training::Page, Training::Video, Training::Question]
    def self.by_id(id)
      find(id)
    end

    # @return [nil, Training::Module]
    def parent
      return if interruption_page?

      @parent ||= Training::Module.by_content_id(id)
    end

    # @return [String]
    def debug_summary
      <<~SUMMARY
        uid: #{id}
        module uid: #{parent.id}
        module name: #{parent.name}
        path: #{name}
        published at: #{published_at}
        page type: #{page_type}

        ---
        previous: #{previous_item&.name}
        next: #{next_item&.name}

        ---
        submodule: #{submodule}
        topic: #{topic}

        ---
        position in module: #{(position_within_module + 1).ordinalize}
        position in submodule: #{position_within_submodule ? (position_within_submodule + 1).ordinalize : 'N/A'}
        position in topic: #{position_within_topic ? (position_within_topic + 1).ordinalize : 'N/A'}

        ---
        submodule items count: #{number_within_submodule}
        topic items count: #{number_within_topic}
      SUMMARY
    end

    # DECORATORS ---------------------------------------------------------------

    # @see ApplicationHelper#html_title
    # @return [String]
    def title
      heading
    end

    # @return [String]
    def next_button_text
      if interruption_page?
        'Next'
      elsif next_item.eql?(self) && (Rails.application.preview? || Rails.env.test?)
        'Next page has not been created'
      elsif next_item.assessment_results?
        'Finish test'
      elsif next_item.summative_question? && !summative_question?
        'Start test'
      elsif next_item.certificate?
        'Finish'
      else
        'Next'
      end
    end

    # @return [Boolean]
    def notes?
      text_page? && notes
    end

  end
end
