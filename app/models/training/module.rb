# USE memcache

require_relative 'content'

module Training
  class Module < Content
    # @return [String]
    def self.content_type_id
      'trainingModule'
    end

    # has_many :pages, class_name: 'Training::Page'
    # has_many :questions, class_name: 'Training::Question'
    # has_many :videos, class_name: 'Training::Video'

    # internal query interface (shallow (and lazy?)) ---------------------------------

    # NB: @return [Contentful::Array] unless `to_a` is called
    #
    # @return [Array<Training::Module>]
    def self.ordered
      # load_children(0).order(:position).load!.to_a
      load_children(0).order(:position).load.to_a
    end

    # @return [Training::Module]
    def self.by_id(id)
      load_children(0).find(id)
    end

    # @return [Training::Module]
    def self.by_name(name)
      load_children(0).find_by(name: name).first
    end

    # entry references ---------------------------------

    # NB specific type lookup order changes as entries are edited

    # # @param type [String] x_page, ...
    # # @return [Array<Training::Page>]
    # def pages_by_type(type)
    #   Training::Page.where_type(name, type)
    # end

    # # @param type [String] x_questionnaire, ...
    # # @return [Array<Training::Question>]
    # def questions_by_type(type)
    #   Training::Question.where_type(name, type)
    # end

    # @example
    #   mod.thumbnail => "//images.ctfassets.net/dvmeh832nmjc/6ICCjd5b2gVc1jMHwgQHpH/a074dbf76e101efcca35dac2e1de6638/1-1-1-1-869488712.jpg"
    #
    # @return [String, nil]
    def thumbnail_url
      return '//external-image-resource-placeholder' if fields[:image].blank?

      ContentfulModel::Asset.find(fields[:image].id).url
    end

    # @return [Training::Module, nil]
    def depends_on
      self.class.by_id(fields[:depends_on].id) if fields[:depends_on]
    end

    # pages is an empty array in a shallow lookup
    # this method enforces order
    #
    # @return [Array<Training::Page, Training::Video, Training::Question>]
    def children
      # @children ||= fields[:pages].map { |child_link| child_by_id(child_link.id) }

      fields[:pages].map do |child_link|
        entry_id = child_link.id

        Rails.logger.info("fetching #{entry_id}")
        puts("fetching #{entry_id}")

        fetch_or_store(entry_id) do # Could use entry cache_key or version with timestamp
          Rails.logger.info("storing #{entry_id}")
          puts("storing #{entry_id}")

          child_by_id(entry_id)
        end
      end
    end

    def content
      children
    end

    # API call gets memoized
    # @private
    # @return [Training::Page, Training::Question, Training::Video] content sought by likelihood (Page more numerous than Video)
    def child_by_id(id)
      Training::Page.by_id(id) || Training::Question.by_id(id) || Training::Video.by_id(id)
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

    # state ---------------------------------

    # @return [Boolean]
    def draft?
      # pages.none?         # expensive and requires loading entries
      fields[:pages].none? # cheap and available even when loading shallow
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

    # [
    #   "interruption_page",
    #   "icons_page",
    #   "module_intro",
    #   "sub_module_intro",
    #   "text_page",
    #   ...
    # ]

    # @return [page] page 1
    def interruption_page
      # pages_by_type('interruption_page').first  # lookup
      content.find(&:interruption_page?)

      # Hit Contentful only if the array of content is not already populated

      # if @children.present?
      #   content.find(&:interruption_page?)
      # else
      #   pages_by_type('interruption_page').first
      # end
    end

    # @return [page] page 2
    def icons_page
      # pages_by_type('icons_page').first
      content.find(&:icons_page?)
    end

    # @return [page] page 3
    def intro_page
      # pages_by_type('module_intro').first
      content.find(&:module_intro?)
    end

    # Viewing this page determines if the module is "started"
    # @return [Training::Page]
    def first_content_page
      # pages_by_type('text_page').first
      text_pages.first
    end

    # @return [Training::Page]
    def summary_intro_page
      # pages_by_type('summary_intro').first
      content.find(&:summary_intro?)
    end

    # @return [Training::Page]
    def assessment_intro_page
      # pages_by_type('assessment_intro').first
      content.find(&:assessment_intro?)
    end

    # @return [Training::Page]
    def assessment_results_page
      # pages_by_type('assessment_results').first
      content.find(&:assessment_results?)
    end

    # @return [Training::Page]
    def confidence_intro_page
      # pages_by_type('confidence_intro').first
      content.find(&:confidence_intro?)
    end

    # @return [Training::Page]
    def thankyou_page
      # pages_by_type('thankyou').first
      content.find(&:thankyou?)
    end

    # @return [Training::Page]
    def certificate_page
      # pages_by_type('certificate').first
      content.find(&:certificate?)
    end

    # collections ---------------------------------

    # @return [Array<Training::Question>]
    def formative_questions
      # questions_by_type('formative_questionnaire')
      content.select(&:formative_question?)
    end

    # @return [Array<Training::Question>]
    def summative_questions
      # questions_by_type('summative_questionnaire')
      content.select(&:summative_question?)
    end

    # @return [Array<Training::Question>]
    def confidence_questions
      # questions_by_type('confidence_questionnaire')
      content.select(&:confidence_question?)
    end

    # @return [Array<Training::Video>]
    def video_pages
      # children_by_type('video_page')
      # Training::Video.where_type(name, type)
      content.select(&:video_page?)
    end

    # @return [Array<Training::Page>]
    def text_pages
      content.select(&:text_page?)
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
  end
end
