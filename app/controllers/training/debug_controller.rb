# :nocov:
module Training
  class DebugController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!, only: :show

    helper_method :mod,
                  :module_table

    layout 'main_hero'

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
    def show; end

  protected

    # @see Learning
    # @return [String]
    def mod_name
      params[:training_module_id]
    end
  end
end
# :nocov:
