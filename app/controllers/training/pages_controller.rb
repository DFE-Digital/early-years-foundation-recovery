module Training
  class PagesController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!
    before_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :section_bar,
                  :module_progress,
                  :note,
                  :pdf?

    layout 'hero'

    def index
      redirect_to training_module_page_path(mod_name, 'what-to-expect')
    end

    def show
      if content.is_question?
        redirect_to training_module_question_path(mod.name, content.name)
      elsif content.assessment_results?
        redirect_to training_module_assessment_path(mod.name, content.name)
      else
        log_caching { render_page }
      end
    end

  private

    def note
      current_user
        .notes
        .where(training_module: mod.name, name: content.name)
        .first_or_initialize(title: content.heading)
    end

    def render_page
      if content.section? && !content.certificate?
        render 'section_intro'
      elsif content.interruption_page?
        render content.page_type, layout: 'application'
      else
        render content.page_type
      end
    rescue ActionView::MissingTemplate
      render 'text_page'
    end

    def track_events
      migrate_progress_if_needed
      record_page_view

      if track_module_start?
        track('module_start')
        helpers.calculate_module_state
      elsif track_confidence_check_complete?
        track('confidence_check_complete')
      elsif track_module_complete?
        track('module_complete')
        record_module_completion
        helpers.calculate_module_state
      end
    end

    def migrate_progress_if_needed
      return if current_user.user_module_progress.exists?

      has_module_events = current_user.events
        .where(name: %w[module_start module_content_page page_view])
        .exists?

      return unless has_module_events

      Training::Module.live.each do |m|
        UserModuleProgress.migrate_from_events(user: current_user, module_name: m.name)
      end
    end

    # @see Tracking
    # @return [Hash]
    def tracking_properties
      { type: content.page_type, uid: content.id, mod_uid: mod.id }
    end

    # @return [Boolean]
    def track_module_complete?
      return false unless content.certificate?

      !untracked?('module_start', training_module_id: mod.name) && untracked?('module_complete', training_module_id: mod.name)
    end

    # @return [Boolean]
    def track_module_start?
      content.submodule_intro? && untracked?('module_start', training_module_id: mod.name)
    end

    # @return [Boolean]
    def track_confidence_check_complete?
      content.thankyou? && untracked?('confidence_check_complete', training_module_id: mod.name)
    end

    # @return [Boolean]
    def pdf?
      request.original_url.end_with?('.pdf')
    end

    def record_page_view
      UserModuleProgress.record_page_view(
        user: current_user,
        module_name: mod.name,
        page_name: content.name,
      )
    end

    def record_module_completion
      UserModuleProgress.record_completion(user: current_user, module_name: mod.name)
    end
  end
end
