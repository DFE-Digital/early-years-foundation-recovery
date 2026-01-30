# Overall module progress:
#   - whether a page was visited
#   - whether any/all/no pages in a section were visited
#   - whether key events have been recorded (start/complete)
#   - the last page visited
#   - the furthest page visited
#
class ModuleProgress
  attr_reader :user, :mod

  # @param user [User]
  # @param mod [Training::Module]
  # @param user_module_progress [UserModuleProgress, nil, :preloaded_nil]
  #   Provide a preloaded record (or :preloaded_nil) to avoid extra queries.
  def initialize(user:, mod:, user_module_progress: :not_provided)
    @user = user
    @mod = mod
    @summative_assessment = AssessmentProgress.new(user: user, mod: mod)
    @user_module_progress = if user_module_progress == :not_provided
                              UserModuleProgress.find_by(user: user, module_name: mod.name)
                            else
                              user_module_progress
                            end
  end

  # @return [Float] Module completion
  def value
    total = mod.content_count
    return 0.0 if total.zero?

    visited_count.to_f / total
  end

  # @return [Integer] number of visited pages
  def visited_count
    @user_module_progress&.visited_pages_count || 0
  end

  # @return [Integer] number of unvisited pages
  def unvisited_count
    mod.content_count - visited_count
  end

  # Name of last page viewed in module
  # @return [String, nil]
  def milestone
    @user_module_progress&.last_page
  end

  # Assumes gaps in page views due to skipping or revisions to content
  # @return [Training::Page, Training::Question, Training::Video]
  def furthest_page
    visited.last
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def resume_page
    mod.page_by_name(milestone) || mod.first_content_page
  end

  # @see CourseProgress
  # @return [Boolean]
  def completed?
    @user_module_progress&.completed_at.present?
  end

  # @see CourseProgress
  # @return [Boolean]
  def started?
    @user_module_progress&.started_at.present?
  end

  # @param page [Training::Page, Training::Question, Training::Video]
  # @return [Boolean]
  def visited?(page)
    @user_module_progress&.visited?(page.name) || false
  end

  # Completed date for module
  # @return [DateTime, nil]
  def completed_at
    @user_module_progress&.completed_at
  end

protected

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] all items viewed
  def all?(content)
    state(:all?, content)
  end

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] some items viewed
  def any?(content)
    state(:any?, content)
  end

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] no items viewed
  def none?(content)
    state(:none?, content)
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def failed_attempt?
    @summative_assessment.attempted? && @summative_assessment.failed?
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def successful_attempt?
    @summative_assessment.passed?
  end

  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def visited
    mod.content.select { |page| visited?(page) }
  end

  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def unvisited
    mod.content.reject { |page| visited?(page) }
  end

private

  # @param method [Symbol]
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  #
  # @return [Boolean]
  def state(method, content)
    content.send(method) { |page| visited?(page) }
  end
end
