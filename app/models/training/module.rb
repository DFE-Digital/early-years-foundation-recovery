module Training
  class Module < Content
    # @return [String]
    def self.content_type_id
      'trainingModule'
    end

    # TODO: deprecate
    def module_items
      content
    end

    # has_many :pages, class_name: 'Training::Page'
    # has_many :questions, class_name: 'Training::Question'
    # has_many :videos, class_name: 'Training::Video'

    # @return [Array<Training::Module>]
    def self.ordered
      return load_children(0).order(:position).load!.to_a if Rails.application.live?

      fetch_or_store(__method__) do
        load_children(0).order(:position).load!.to_a
      end
    end

    # cached queries ---------------------------------
    #
    # TODO: use webhooks to expire cached result
    #
    #   def clear_cache_for(item_id)
    #     cache_key = timestamp_cache_key(item_id)
    #     Rails.cache.delete(cache_key)
    #   end

    # @return [Training::Module] cached result
    def self.by_id(id)
      return load_children(0).find(id) if Rails.application.live?

      fetch_or_store(id) do
        load_children(0).find(id)
      end
    end

    # @return [Training::Module] cached result
    def self.by_name(name)
      return load_children(0).find_by(name: name.to_s).first if Rails.application.live?

      fetch_or_store(name.to_s) do
        load_children(0).find_by(name: name.to_s).first
      end
    end

    # entry references ---------------------------------

    # @example
    #   mod.thumbnail => "//images.ctfassets.net/dvmeh832nmjc/6ICCjd5b2gVc1jMHwgQHpH/a074dbf76e101efcca35dac2e1de6638/1-1-1-1-869488712.jpg"
    #
    # @return [String, nil] cached result
    def thumbnail_url
      return '//external-image-resource-placeholder' if fields[:image].blank?
      return ContentfulModel::Asset.find(fields[:image].id).url if Rails.application.live?

      fetch_or_store(fields[:image].id) do
        ContentfulModel::Asset.find(fields[:image].id).url
      end
    end

    # @return [Training::Module, nil] cached result
    def depends_on
      self.class.by_id(fields[:depends_on].id) if fields[:depends_on]
    end

    # source of truth for content order
    #
    # @return [Array<Training::Page, Training::Video, Training::Question>] cached result
    def content
      return [] if draft?

      fields[:pages].map do |child_link|
        if Rails.application.live?
          child_by_id(child_link.id)
        else
          fetch_or_store(child_link.id) { child_by_id(child_link.id) }
        end
      end
    end

    # @return [Hash{ Integer=>Array<Module::Content> }]
    def content_by_submodule
      content.group_by(&:submodule).except(0)
    end

    # @return [Hash{ Array<Integer> => Array<Module::Content> }]
    def content_by_submodule_topic
      content.group_by { |page|
        [page.submodule, page.topic] unless page.topic.zero?
      }.except(nil)
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
      content.find { |page| page.id.eql?(id) }
    end

    # Selects from ordered array
    #
    # @return [Training::Page, Training::Video, Training::Question]
    def page_by_name(name)
      content.find { |page| page.name.eql?(name) }
    end

    # Selects from ordered array
    #
    # @return [Array<Training::Page, Training::Video, Training::Question>]
    def page_by_type(type)
      content.select { |page| page.page_type.eql?(type) }
    end

    # state ---------------------------------

    # This approach is inline with Contenful's conventions.
    # In staging draft modules should appear as published.
    # The content team will select all pages and change them from draft to published, thereby changing the status on production.
    #
    # @return [Boolean]
    def draft?
      fields.fetch(:pages, []).none?
    end

    # # @return [Datetime]
    # delegate :published_at, to: :entry

    # # NB: Adds additional call to Management API (per-dev tokens may need to bestow access to the active env)
    # #
    # # @see ContentfulCourseProgress#debug_summary
    # # @return [Contentful::Management::Entry]
    # def entry
    #   @entry ||= to_management
    # rescue NoMethodError
    #   @entry = refetch_management_entry
    # end

    # content pages ---------------------------------

    # @return [Training::Page]
    def first_content_page
      text_pages.first
    end

    # @return [Training::Page]
    def interruption_page
      content.find(&:interruption_page?)
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

    # collections ---------------------------------

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

    # view decorators ---------------------------------

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

  private

    # @return [Training::Page, Training::Question, Training::Video] content sought by likelihood (Page more numerous than Video)
    def child_by_id(id)
      Training::Page.by_id(id) || Training::Question.by_id(id) || Training::Video.by_id(id)
    end
  end
end
