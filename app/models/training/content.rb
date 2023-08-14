module Training
  class Content < ContentfulModel::Base
    # @return [Boolean]
    def topic_page_name?
      name.match? %r"\A(?<prefix>\d+\W){3}(?<page>\d+\D*)$"
    end

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

    # NB: do not apply additional caching here
    # @return [Training::Content]
    def self.by_id(id)
      find(id)
    end

    # @return [nil, Training::Module]
    def parent
      return if interruption_page?

      @parent ||= Training::Module.by_content_id(id)
    end

    # @return [nil, Training::Page, Training::Video, Training::Question]
    def previous_item
      return if interruption_page?

      parent.page_by_id(previous_item_id)
    end

    # @note Whilst being authored, reload if the next page is yet to be created
    #
    # @return [Training::Page, Training::Video, Training::Question]
    def next_item
      parent.page_by_id(next_item_id) || self
    end

    # private
    # @return [String] Contentful Link ID
    def previous_item_id
      parent.fields[:pages][position_within_module - 1].id
    end

    # private
    # @return [String, nil] Contentful Link ID
    def next_item_id
      parent.fields[:pages][position_within_module + 1]&.id
    end

    # Can be found without loading all content
    #
    # @return [Integer] (zero index)
    def position_within_module
      parent.fields[:pages].rindex { |child_link| child_link.id.eql?(id) }
    end

    # Needs full entries to be loaded
    #
    # @return [Integer] (zero index)
    def position_within_submodule
      current_submodule_items.index(self)
    end

    # @return [Integer] (zero index)
    def position_within_topic
      current_submodule_topic_items.index(self)
    end

    # @return [Array<Training::Page, Training::Video, Training::Question>] content in the same submodule
    def current_submodule_items
      parent.content.select { |page| page.submodule.eql?(submodule) }
    end

    # @return [Array<Training::Page, Training::Video, Training::Question>] content in the same submodule and topic
    def current_submodule_topic_items
      current_submodule_items.select { |page| page.topic.eql?(topic) }
    end

    # counters ---------------------------------

    # @return [Integer] number of submodule items 1-[1]-1-1, (excluding intro)
    def number_within_submodule
      if module_intro?
        0
      else
        current_submodule_items.count - 1
      end
    end

    # @return [Integer] number of topic items 1-1-[1]-1
    def number_within_topic
      current_submodule_topic_items.count
    end

    # decorators ---------------------------------

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
    def submodule_intro?
      page_type.eql?('sub_module_intro')
    end

    # @return [Boolean]
    def summary_intro?
      page_type.eql?('summary_intro')
    end

    # @return [Boolean]
    def module_intro?
      page_type.eql?('module_intro')
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
    def icons_page?
      page_type.eql?('icons_page')
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

    # @return [Boolean]
    def page_numbers?
      case page_type
      when /intro|thankyou/ then false
      else
        true
      end
    end

    # @return [Hash{Symbol => nil, Integer}]
    def pagination
      { current: position_within_submodule, total: number_within_submodule }
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
