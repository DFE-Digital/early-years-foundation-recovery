module Training
  class Content < ContentfulModel::Base
    extend Dry::Core::Cache

    # METHODS TO DEPRECATE --------------------------------------

    # @return [self]
    def module_item
      self
    end

    # @return [self]
    def model
      self
    end

    # @return [Training::?]
    def self.by_id(id)
      load_children(0).find(id)
    end

    # # @return [Training::?]
    # def self.by_name(mod_name: mod_name, page_name: page_name)
    #   load_children(0).find_by(name: page_name, training_module: { name: mod_name }).first
    # end

    # # @param mod_name [String]
    # # @param page_type [String]
    # # @return [Array<Training::Content, ...>]
    # def self.where_type(mod_name, page_type)
    #   load_children(0).find_by(training_module: { name: mod_name }, page_type: page_type).order(:name).load
    # end

    # # @param mod_name [String]
    # # @param submodule [Integer]
    # # @return [Array<Training::Content, ...>]
    # def self.where_submodule(mod_name, submodule)
    #   load_children(0).find_by(training_module: { name: mod_name }, submodule: submodule).order(:name).load
    # end

    # # @param mod_name [String]
    # # @param submodule [Integer]
    # # @param topic [Integer]
    # # @return [Array<Training::Content, ...>]
    # def self.where_submodule_topic(mod_name, submodule, topic)
    #   load_children(0).find_by(training_module: { name: mod_name }, submodule: submodule, topic: topic).order(:name).load
    # end

    # METHODS TO DEPRECATE --------------------------------------

    # linear progression ----------------------------------------------------------

    # backwards compatibility
    # @return [String]
    # def training_module
    #   parent.name
    # end

    # @return [Training::Module]
    def parent
      # @parent ||= Training::Module.by_id(fields[:training_module].id)

      entry_id = fields[:training_module].id

      Rails.logger.info("fetching #{entry_id}")
      fetch_or_store(entry_id) do
        Rails.logger.info("storing #{entry_id}")
        Training::Module.by_id(entry_id)
      end
    end

    # @return [Training::Page, Training::Video, Training::Question, nil]
    def previous_item
      return if first?

      parent.page_by_id(previous_item_id)
    end

    # @return [Boolean]
    def first?
      position_within_module.zero?
    end

    # @return [Training::Page, Training::Video, Training::Question, nil]
    def next_item
      parent.page_by_id(next_item_id)
    end

    # private
    # @return [String] Contentful Link ID
    def previous_item_id
      parent.fields[:pages][position_within_module - 1].id
    end

    # private
    # @return [String] Contentful Link ID
    def next_item_id
      parent.fields[:pages][position_within_module + 1].id
    end

    # Can be found without loading all content
    #
    # @return [Integer] (zero index)
    def position_within_module
      # if parent.instance_variable_set?(:@children)
      # content.index(self) # all children loaded
      # else
      parent.fields[:pages].rindex { |child_link| child_link.id.eql?(id) }
      # end
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

    # @return [Array<Training::Content, ....>] content in the same submodule
    def current_submodule_items
      parent.content.select { |page| page.submodule.eql?(submodule) }
    end

    # @return [Array<Training::Content, ....>] content in the same submodule and topic
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

    # @return [String]
    def next_button_text
      if next_item.assessment_results?
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
      notes
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
      page_type.match?(/formative summative confidence/)
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

    # names ---------------------------------

    # # @return [String, nil] 2nd digit if present: 1-[1]-1-1
    # def submodule_name
    #   matches = name.match(ModuleItem::SUBMODULE_PATTERN)
    #   matches[:submodule] if matches
    # end

    # # @return [String, nil] 3rd digit if present: 1-1-[1]-1
    # def topic_name
    #   matches = name.match(ModuleItem::TOPIC_PATTERN)
    #   matches[:topic] if matches
    # end

    # # @return [String, nil] 4th digit (and optional suffix) if present: 1-1-1-[1a]
    # def page_name
    #   matches = name.match(ModuleItem::PAGE_PATTERN)
    #   matches ? matches[:page] : 0
    # end

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
        id: #{id}
        name: #{parent.name}
        path: #{name}
        page type: #{page_type}
        module_item: #{module_item}

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
