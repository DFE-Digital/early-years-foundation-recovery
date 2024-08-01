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

    # @return [Boolean]
    def edited?
      if Rails.application.preview?
        created_at < updated_at
      elsif published_at.present?
        published_at < updated_at
      else
        false
      end
    end

    # @return [DateTime, nil]
    def published_at
      module_release&.first_published_at
    end

    # @param mod [Course, Training::Module]
    # @return [Training::Page, Training::Video, Training::Question]
    def with_parent(mod)
      @parent = mod
      self
    end

    # @return [String]
    def debug_summary
      <<~SUMMARY
        uid: #{id}
        module uid: #{parent.id}
        module name: #{parent.name}
        published at: #{published_at || 'Management Key Missing'}
        page type: #{page_type}

        ---
        previous: #{previous_item&.name}
        current: #{name}
        next: #{next_item&.name}

        ---
        submodule: #{submodule}
        topic: #{topic}

        ---
        position in module: #{position_within(parent.pages)}
        position in submodule: #{position_within(section_content)}
        position in topic: #{position_within(subsection_content)}

        ---
        pages in submodule: #{section_size}
        pages in topic: #{subsection_size}
      SUMMARY
    end

    # DECORATORS ---------------------------------------------------------------

    # @see ApplicationHelper#html_title
    # @return [String]
    def title
      heading
    end

    # @return [Boolean]
    def notes?
      (topic_intro? || text_page?) && notes
    end

    # @return [Boolean]
    def skippable?
      false
    end

  private

    def module_release
      ModuleRelease.find_by(module_position: parent.position)
    end
  end
end
