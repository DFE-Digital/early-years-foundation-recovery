class UserModuleProgress < ApplicationRecord
  self.table_name = 'user_module_progress'

  belongs_to :user

  validates :module_name, presence: true
  validates :module_name, uniqueness: { scope: :user_id }

  scope :started, -> { where.not(started_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { started.where(completed_at: nil) }

  # @return [Integer, nil] seconds taken to complete, nil if not completed
  def time_to_completion
    return nil unless completed_at && started_at

    (completed_at - started_at).to_i
  end

  # @param page_name [String]
  # @return [Boolean]
  def visited?(page_name)
    visited_pages&.key?(page_name)
  end

  # @return [Array<String>]
  def visited_page_names
    visited_pages&.keys || []
  end

  # @return [Integer]
  def visited_pages_count
    visited_pages&.size || 0
  end

  # @param user [User]
  # @param module_name [String]
  # @return [UserModuleProgress]
  def self.record_start(user:, module_name:)
    progress = find_or_initialize_by(user: user, module_name: module_name)
    progress.started_at ||= Time.zone.now
    progress.save!
    progress
  end

  # @param user [User]
  # @param module_name [String]
  # @return [UserModuleProgress]
  def self.record_completion(user:, module_name:)
    progress = find_or_initialize_by(user: user, module_name: module_name)
    progress.started_at ||= Time.zone.now
    progress.completed_at ||= Time.zone.now
    progress.save!
    progress
  end

  # @param user [User]
  # @param module_name [String]
  # @param page_name [String]
  # @return [UserModuleProgress]
  def self.record_page_view(user:, module_name:, page_name:)
    progress = find_or_initialize_by(user: user, module_name: module_name)
    progress.started_at ||= Time.zone.now
    progress.visited_pages ||= {}
    progress.visited_pages[page_name] ||= Time.zone.now.iso8601
    progress.last_page = page_name
    progress.save!
    progress
  end

  # @param user [User]
  # @param module_name [String]
  # @return [UserModuleProgress, nil]
  def self.migrate_from_events(user:, module_name:)
    progress = find_or_initialize_by(user: user, module_name: module_name)

    start_event = user.events
      .where(name: 'module_start')
      .where_properties(training_module_id: module_name)
      .order(:time)
      .first

    complete_event = user.events
      .where(name: 'module_complete')
      .where_properties(training_module_id: module_name)
      .order(:time)
      .first

    page_events = user.events
      .where(name: %w[module_content_page page_view])
      .where("properties->>'training_module_id' = ?", module_name)
      .order(:time)

    return if progress.new_record? && start_event.nil? && complete_event.nil? && page_events.empty?

    visited = {}
    page_events.each do |event|
      page_name = event.properties['id']
      visited[page_name] ||= event.time&.iso8601 if page_name.present?
    end

    # Merge in the oldest known start and completion times
    user_started_at = [progress.started_at, start_event&.time, page_events.first&.time].compact.min
    user_completed_at = [progress.completed_at, complete_event&.time].compact.min

    progress.started_at = user_started_at if user_started_at && (progress.started_at.nil? || user_started_at < progress.started_at)
    progress.completed_at = user_completed_at if user_completed_at && (progress.completed_at.nil? || user_completed_at < progress.completed_at)

    progress.visited_pages ||= {}
    visited.each do |page_name, timestamp|
      progress.visited_pages[page_name] ||= timestamp
    end

    # Avoid overwriting newer "last_page" tracked by the new system
    if progress.last_page.blank? && page_events.any?
      progress.last_page = page_events.last&.properties&.dig('id')
    end

    progress.save!
    progress
  end
end
