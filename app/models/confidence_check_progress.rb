class ConfidenceCheckProgress < ApplicationRecord
  self.table_name = 'confidence_check_progress'

  belongs_to :user

  validates :module_name, presence: true
  validates :check_type, presence: true, inclusion: { in: %w[pre post] }
  validates :module_name, uniqueness: { scope: %i[user_id check_type] }

  scope :pre_check, -> { where(check_type: 'pre') }
  scope :post_check, -> { where(check_type: 'post') }
  scope :started, -> { where.not(started_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :skipped, -> { where.not(skipped_at: nil).where(completed_at: nil) }

  # @return [Integer, nil] seconds taken to complete, nil if not completed
  def time_to_completion
    return nil unless completed_at && started_at

    (completed_at - started_at).to_i
  end

  # @param user [User]
  # @param module_name [String]
  # @param check_type [String] "pre" or "post"
  # @return [ConfidenceCheckProgress]
  def self.record_start(user:, module_name:, check_type:)
    progress = find_or_initialize_by(user: user, module_name: module_name, check_type: check_type)
    progress.started_at ||= Time.zone.now
    progress.save!
    progress
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  # @param user [User]
  # @param module_name [String]
  # @param check_type [String] "pre" or "post"
  # @return [ConfidenceCheckProgress]
  def self.record_completion(user:, module_name:, check_type:)
    progress = find_or_initialize_by(user: user, module_name: module_name, check_type: check_type)
    progress.started_at ||= Time.zone.now
    progress.completed_at ||= Time.zone.now
    progress.save!
    progress
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  # @param user [User]
  # @param module_name [String]
  # @return [ConfidenceCheckProgress, nil]
  def self.record_skip(user:, module_name:)
    progress = find_or_initialize_by(user: user, module_name: module_name, check_type: 'pre')
    return progress if progress.completed_at.present?

    progress.skipped_at ||= Time.zone.now
    progress.save!
    progress
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
