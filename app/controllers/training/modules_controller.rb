module Training
  class ModulesController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!, only: :show

    helper_method :mod,
                  :progress_bar,
                  :module_progress,
                  :module_table

    layout 'hero'

    def show
      track('module_overview_page', mod_uid: mod.id)

      redirect_to my_modules_path if redirect?
    end

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

    # @see Learning
    # @return [String]
    def mod_name
      params.permit(:id)[:id]
    end
  end
end
