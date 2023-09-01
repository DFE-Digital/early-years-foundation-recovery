module Training
  class Module < ContentfulModel::Base
    validates_presence_of :name

    include ::Management

    extend ::Caching

    # @return [String]
    def self.content_type_id
      'trainingModule'
    end

    # @return [Array<Training::Module>]
    def self.ordered
      fetch_or_store to_key("#{name}.__method__") do
        order(:position).load.to_a.select(&:named?)
      end
    end

    # @return [Array<Training::Module>]
    def self.live
      ordered.reject(&:draft?)
    end

    # @param id [String]
    # @return [Training::Module]
    def self.by_id(id)
      fetch_or_store to_key(id) do
        find(id)
      end
    end

    # @param name [String]
    # @return [Training::Module]
    def self.by_name(name)
      fetch_or_store to_key(name) do
        find_by(name: name.to_s).first
      end
    end

    # @param id [String]
    # @return [Training::Module]
    def self.by_content_id(id)
      ordered.find { |mod| mod.content.find { |content| content.id.eql?(id) } }
    end

    # @return [String]
    def debug_summary
      <<~SUMMARY
        cms id: #{id}
        path: #{name}
        published at: #{published_at}
        duration: #{duration}
        submodules: #{submodule_count}
        topics: #{topic_count}
        questions: #{questions.count}
        last page: #{content.last.name}
        certificate: #{certificate_page.name}
      SUMMARY
    end

    # entry references ---------------------------------

    # @example
    #   mod.thumbnail => "//images.ctfassets.net/dvmeh832nmjc/6ICCjd5b2gVc1jMHwgQHpH/a074dbf76e101efcca35dac2e1de6638/1-1-1-1-869488712.jpg"
    #
    # @return [String, nil] cached result
    def thumbnail_url
      return '//external-image-resource-placeholder' if fields[:image].blank?

      fetch_or_store self.class.to_key(fields[:image].id) do
        ContentfulModel::Asset.find(fields[:image].id).url
      end
    end

    # @return [Array<Training::Page, Training::Video, Training::Question>]
    def content
      pages.reject(&:interruption_page?)
    end

    # SECTIONS -----------------------------------------------------------------

    # @return [Hash{ Integer => Array<Training::Page, Training::Video, Training::Question> }]
    def content_by_submodule
      content.slice_before(&:section?).each.with_index(1).to_h.invert
    end

    # @return [Hash{ Array<Integer> => Array<Training::Page, Training::Video, Training::Question> }]
    def content_by_submodule_topic
      sections = content.slice_before(&:section?).each.with_index(1).map do |section_entries, submodule_num|
        section_entries.slice_before(&:subsection?).each.with_index(1).map do |subsection_entries, topic_num|
          { [submodule_num, topic_num] => subsection_entries }
        end
      end

      sections.flatten.reduce(&:merge)
    end

    # @return [Integer]
    def topic_count
      content_by_submodule_topic.count
    end

    # @return [Integer]
    def submodule_count
      content_by_submodule.count
    end

    # Selects from ordered array
    #
    # @return [Training::Page, Training::Video, Training::Question]
    def page_by_id(id)
      pages.find { |page| page.id.eql?(id) }
    end

    # Selects from ordered array
    #
    # @return [Training::Page, Training::Video, Training::Question]
    def page_by_name(name)
      pages.find { |page| page.name.eql?(name) }
    end

    # Selects from ordered array
    #
    # @return [Array<Training::Page, Training::Video, Training::Question>]
    def page_by_type(type)
      pages.select { |page| page.page_type.eql?(type) }
    end

    # STATE --------------------------------------------------------------------

    # TODO: consider terminology and replace #draft? with #invalid?
    #
    # @see CourseProgress
    # @return [Boolean] incomplete content will not be deemed 'available'
    def draft?
      @draft ||= !data.valid?
    end

    # @return [Boolean]
    def named?
      name.present?
    end

    # @return [Boolean]
    def pages?
      Array(fields[:pages]).any?
    end

    # SINGLE ENTRY -------------------------------------------------------------

    # @return [Training::Page]
    def content_start
      page_by_type('sub_module_intro').first
    end

    # @return [Training::Page]
    def first_content_page
      page_by_type('topic_intro').first
    end

    # @return [Training::Page]
    def interruption_page
      pages.find(&:interruption_page?)
    end

    # @return [Training::Page]
    def summary_intro_page
      content.find(&:summary_intro?)
    end

    # @return [Training::Page]
    def assessment_intro_page
      content.find(&:assessment_intro?)
    end

    # @return [Training::Page]
    def assessment_results_page
      content.find(&:assessment_results?)
    end

    # @return [Training::Page]
    def confidence_intro_page
      content.find(&:confidence_intro?)
    end

    # @return [Training::Page]
    def thankyou_page
      content.find(&:thankyou?)
    end

    # @return [Training::Page]
    def certificate_page
      content.find(&:certificate?)
    end

    # MANY ENTRIES -------------------------------------------------------------

    # @return [Array<Training::Page>]
    def text_pages
      content.select(&:text_page?)
    end

    # @return [Array<Training::Video>]
    def video_pages
      content.select(&:video_page?)
    end

    # @return [Array<Training::Question>]
    def questions
      content.select(&:is_question?)
    end

    # @return [Array<Training::Question>]
    def formative_questions
      content.select(&:formative_question?)
    end

    # @return [Array<Training::Question>]
    def summative_questions
      content.select(&:summative_question?)
    end

    # @return [Array<Training::Question>]
    def confidence_questions
      content.select(&:confidence_question?)
    end

    # @param text [String]
    # @return [Array<String>]
    def answers_with(text)
      questions.select { |q| q.answer.contains?(text) }.map(&:name)
    end

    # DECORATORS ---------------------------------------------------------------

    # @return [String]
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
      "#module-#{position}-#{title.downcase.parameterize}"
    end

    # @return [Array<Array>] AST for automated module completion
    def schema
      pages.map(&:schema)
    end

    # @return [ContentIntegrity]
    def data
      @data ||= ContentIntegrity.new(module_name: name)
    end
  end
end
