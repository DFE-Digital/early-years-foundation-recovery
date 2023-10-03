module Training
  class ModulesController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!, only: :show
    layout 'main_hero'

    helper_method :mod,
                  :progress_bar,
                  :module_progress,
                  :mods,
                  :module_table

    def index
      track('course_overview_page', cms: true)
    end

    def show
      track('module_overview_page', mod_uid: mod.id)

      redirect_to my_modules_path if redirect?
    end

    # @see ModuleDebugDecorator
    #
    # @example
    #   /modules/alpha/structure
    #
    # Position  Visited Sections        Progress  Submodule Topic Pages       Model Type              Name
    # --------------------------------------------------------------------------------------------------------------------------
    # 1st       true    Section 1 of 5  14%       1         0     Page 1 of 7 page  sub_module_intro  content-management-system
    # 2nd       true    Section 1 of 5  29%       1         1     Page 2 of 7 page  topic_intro       glossary-of-terms
    # 3rd       false   Section 1 of 5  43%       1         2     Page 3 of 7 page  topic_intro       bespoke-markup
    #
    def structure; end

  protected

    # @return [Boolean]
    def redirect?
      mod.nil? || unreleased? || wip?
    end

    # When authoring a new module the overview page will not be accessible until
    # the module has some content. This will generate an application error unless
    # the module content passes the data integrity check.
    #
    # @return [Boolean]
    def wip?
      Rails.application.preview? && !mod.pages?
    end

    # @return [Boolean]
    def unreleased?
      !Rails.application.preview? && mod.draft?
    end

    # @return [Array<Training::Module>]
    def mods
      Training::Module.ordered
    end

    # @see Learning
    # @return [String]
    def mod_name
      params[:id]
    end
  end
end
