class UserModuleProgress < ApplicationRecord
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
    progress.started_at ||= Time.zone.now # Ensure started_at is set
    progress.completed_at ||= Time.zone.now
    progress.save!
    progress
  end
end
