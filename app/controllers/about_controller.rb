class AboutController < ApplicationController
  helper_method :mods,
                :mod

  layout 'hero'

  def show
    redirect_to course_overview_path if mod.draft?
    track('about_module_page', cms: true, mod: mod.name, mod_uid: mod.id)
  end

  def experts
    track('experts_page', cms: true)
  end

  def course
    track('course_overview_page', cms: true)
  end

private

  # @return [Array<Training::Module>]
  def mods
    Training::Module.ordered
  end

  # @return [::Training::Module]
  def mod
    ::Training::Module.by_name(params.permit(:id)[:id])
  end
end
