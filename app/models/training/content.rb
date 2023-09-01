module Training
  class Content < ContentfulModel::Base
    include ::Pagination

    # @return [String, nil]
    def published_at
      return unless Rails.env.development? && ENV['CONTENTFUL_MANAGEMENT_TOKEN'].present?

      entry.published_at&.in_time_zone(ENV['TZ'])&.strftime('%d-%m-%Y %H:%M')
    end

    # @see Training::Content#debug_summary
    # @return [Contentful::Management::Entry]
    def entry
      @entry ||= to_management
    rescue NoMethodError, Errno::ECONNREFUSED
      @entry = refetch_management_entry
    end

    # @return [Training::Page, Training::Video, Training::Question]
    def self.by_id(id)
      find(id)
    end

    # @return [nil, Training::Module]
    def parent
      return if interruption_page?

      @parent ||= Training::Module.by_content_id(id)
    end

    # SECTIONS -----------------------------------------------------------------

    # @return [Boolean]
    def section?
      submodule_intro? || summary_intro?
    end

    # @return [Boolean]
    def subsection?
      topic_intro? || recap_page? || assessment_intro? || confidence_intro? || certificate?
    end

    # @return [nil, Integer]
    def submodule
      return if interruption_page?

      submodule, _entries = parent.content_by_submodule.find { |_, values| values.include?(self) }
      submodule
    end

    # @return [nil, Integer]
    def topic
      return if interruption_page?

      (_submodule, topic), _entries = parent.content_by_submodule_topic.find { |_, values| values.include?(self) }
      topic
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

    # predicates ---------------------------------

    # @return [Boolean]
    def notes?
      text_page? && notes
    end

    # intro types ---------------------------------

    # @return [Boolean]
    def module_intro?
      page_type.eql?('module_intro')
    end

    # @return [Boolean]
    def submodule_intro?
      page_type.eql?('sub_module_intro')
    end

    # @return [Boolean]
    def topic_intro?
      page_type.eql?('topic_intro')
    end

    # @return [Boolean]
    def summary_intro?
      page_type.eql?('summary_intro')
    end

    # @return [Boolean]
    def assessment_intro?
      page_type.eql?('assessment_intro')
    end

    # @return [Boolean]
    def confidence_intro?
      page_type.eql?('confidence_intro')
    end

    # question types ---------------------------------

    # @return [Boolean]
    def is_question?
      page_type.match?(/question/)
    end

    # @return [Boolean]
    def summative_question?
      page_type.eql?('summative_questionnaire')
    end

    # @return [Boolean]
    def formative_question?
      page_type.eql?('formative_questionnaire')
    end

    # @return [Boolean]
    def confidence_question?
      page_type.eql?('confidence_questionnaire')
    end

    # basic types ---------------------------------

    # @return [Boolean]
    def text_page?
      page_type.eql?('text_page')
    end

    # @return [Boolean]
    def video_page?
      page_type.eql?('video_page')
    end

    # special types ---------------------------------

    # @return [Boolean]
    def interruption_page?
      page_type.eql?('interruption_page')
    end

    # @return [Boolean]
    def recap_page?
      page_type.eql?('recap_page')
    end

    # @return [Boolean]
    def assessment_results?
      page_type.eql?('assessment_results')
    end

    # @return [Boolean]
    def thankyou?
      page_type.eql?('thankyou')
    end

    # @return [Boolean]
    def certificate?
      page_type.eql?('certificate')
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
  end
end
