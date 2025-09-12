require 'google/cloud/storage'

class Dashboard
  extend Dry::Initializer

  # @!attribute [r] bucket_name
  #   @return [String]
  option :bucket_name, Types.Instance(String), default: proc { Rails.application.config.google_cloud_bucket }
  # @!attribute [r] path
  #   @return [Pathname]
  option :path, Types.Instance(Pathname), required: true

  # @return [Array<Hash{ Symbol => String }>]
  DATA_SOURCES = [
    { model: 'Event',                                   folder: 'events',   file: 'events'                        },

    { model: 'Visit',                                   folder: 'visits',   file: 'visits'                        },

    { model: 'DataAnalysis::UserOverview',              folder: 'users',    file: 'user_overview'                 },
    { model: 'User',                                    folder: 'users',    file: 'users'                         },
    { model: 'DataAnalysis::ClosedAccounts',            folder: 'users',    file: 'closed_accounts'               },
    { model: 'DataAnalysis::ReturningUsers',            folder: 'users',    file: 'returning_users'               },
    { model: 'DataAnalysis::UserCountByRoleAndExperience', folder: 'users', file: 'user_count_by_role_and_experience' },
    # { model: 'DataAnalysis::LocalAuthorityUser',        folder: 'users',    file: 'local_authority_users'         },

    { model: 'Assessment', folder: 'training', file: 'assessments' },
    { model: 'DataAnalysis::AssessmentForLeadersAndManagers', folder: 'training', file: 'assessments_managers_and_leaders' },
    { model: 'DataAnalysis::ConfidenceCheckScores', folder: 'training', file: 'confidence_check_scores' },
    { model: 'DataAnalysis::ConfidenceCheckScoresForManagerOrLeaderOnly', folder: 'training', file: 'confidence_check_scores_for_manager_or_leader_only' },
    # { model: 'DataAnalysis::AveragePassScores',         folder: 'training', file: 'average_pass_scores'           },
    # { model: 'DataAnalysis::HighFailQuestions',         folder: 'training', file: 'high_fail_questions'           },
    # { model: 'DataAnalysis::SettingPassRate',           folder: 'training', file: 'setting_pass_rate'             },
    # { model: 'DataAnalysis::RolePassRate',              folder: 'training', file: 'role_pass_rate'                },
    # { model: 'DataAnalysis::UsersNotPassing',           folder: 'training', file: 'assessment_failures'           },
    # { model: 'DataAnalysis::ResitsPerUser',             folder: 'training', file: 'resits_per_user'               },
    # { model: 'DataAnalysis::ModulesPerMonth',           folder: 'training', file: 'modules_per_month'             },
    # { model: 'DataAnalysis::ModuleOverview',            folder: 'training', file: 'module_overview'               },
    # { model: 'DataAnalysis::UserModuleOrder',           folder: 'training', file: 'module_order'                  },
    { model: 'DataAnalysis::UserModuleCompletion',      folder: 'training', file: 'module_completion'             },
    { model: 'DataAnalysis::UserModuleCompletionCount', folder: 'training', file: 'module_completions_count'      },
    { model: 'DataAnalysis::UsersStartedNotCompletedByExperience', folder: 'training', file: 'users_started_not_completed_by_experience' },
    { model: 'DataAnalysis::UsersCompletedModuleCountByExperience', folder: 'training', file: 'users_completed_module_count_by_experience' },
    { model: 'DataAnalysis::UserModuleOrderByExperience', folder: 'training', file: 'module_order_by_experience' },

    { model: 'DataAnalysis::GuestFeedbackScores',       folder: 'feedback', file: 'guest_feedback'                },
    { model: 'DataAnalysis::UserFeedbackScores',        folder: 'feedback', file: 'course_feedback'               },
    { model: 'DataAnalysis::ModuleFeedbackForms',       folder: 'feedback', file: 'module_feedback'               },
  ].freeze

  # @return [String] 30-06-2022-09-30
  TIMESTAMP_PATTERN = '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'.freeze

  # @param upload [Boolean] default: false
  # @param clean [Boolean] default: false
  # @return [String]
  def call(upload: false, clean: false)
    purge if clean

    export models_to_csv

    if upload
      rotate_data_sources
    else
      log 'SKIPPING UPLOAD'
    end
  end

private

  # @return [String] 30-06-2022-09-30
  def timestamp
    @timestamp ||= Time.zone.now.strftime('%d-%m-%Y-%H-%M')
  end

  # @return [Pathname]
  def output
    path.join(timestamp)
  end

  # @return [Array<Array>] database table exports
  def models_to_csv
    DATA_SOURCES.map do |source|
      file_data = source[:model].constantize.to_csv
      dir_path  = output.join(source[:folder])
      file_path = dir_path.join("#{source[:file]}.csv")

      [file_data, dir_path, file_path]
    end
  end

  # @return [nil]
  def purge
    Dir.chdir(path) do
      Dir.glob(TIMESTAMP_PATTERN) do |old|
        FileUtils.rm_rf(old, secure: true)
      end
    end
  end

  # @param input [Array<String>] content, path, name
  # @return [String] save to disk
  def export(input)
    input.each do |file_data, dir_path, file_path|
      FileUtils.mkdir_p(dir_path)
      File.write(file_path, file_data)

      log "#{file_path} created"
    end
  end

  # @return [Array<Array>] local, remote, archive
  def models_to_remote_csv
    DATA_SOURCES.map do |source|
      [
        output.join(source[:folder]).join("#{source[:file]}.csv").to_s,
        "#{source[:folder]}/#{source[:file]}.csv",
        "backup/#{source[:folder]}/#{source[:file]}-#{timestamp}.csv",
      ]
    end
  end

  # @note Ruby SDK doesn't support uploading a folder
  #
  # @see https://cloud.google.com/storage/docs/folders
  # @see https://cloud.google.com/storage/docs/deleting-objects#storage-delete-object-ruby
  # @see https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-ruby
  # @see https://cloud.google.com/storage/docs/copying-renaming-moving-objects#storage-copy-object-ruby
  #
  def rotate_data_sources
    models_to_remote_csv.map do |local, remote, backup|
      bucket.file(remote)&.delete
      bucket.upload_file(local, remote)
      bucket.file(remote).copy(bucket_name, backup)

      log "Uploaded #{local} to #{remote} and archived as #{backup} on #{bucket.name}"
    end
  end

  # @return [Google::Cloud::Storage::Bucket]
  def bucket
    @bucket ||= storage.bucket(bucket_name, skip_lookup: true)
  end

  # @return [Hash{String=>String}]
  def credentials
    @credentials ||= JSON.parse(Rails.application.credentials.google_cloud_storage)
  end

  # @return [Google::Cloud::Storage::Project]
  def storage
    Google::Cloud::Storage.new(credentials: credentials, project: credentials['project_id'])
  end

  # @param message [String]
  # @return [String, nil]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    elsif ENV['VERBOSE'].present?
      puts message
    end
  end
end
