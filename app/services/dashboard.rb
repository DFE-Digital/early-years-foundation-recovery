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
    { model: 'Ahoy::Event',                     folder: 'eventsdata',       file: 'ahoy_events'                   },
    { model: 'Ahoy::Visit',                     folder: 'visitsdata',       file: 'ahoy_visits'                   },
    { model: 'User',                            folder: 'userdata',         file: 'users'                         },
    { model: 'UserAnswer',                      folder: 'useranswers',      file: 'user_answers'                  },
    { model: 'Response',                        folder: 'useranswers',      file: 'responses'                     },
    { model: 'UserAssessment',                  folder: 'userassessments',  file: 'user_assessments'              },
    { model: 'Data::LocalAuthorityUser',        folder: 'localauthorities', file: 'local_authority_users'         },
    { model: 'Data::AveragePassScores',         folder: 'summativequiz',    file: 'average_pass_scores'           },
    { model: 'Data::HighFailQuestions',         folder: 'summativequiz',    file: 'high_fail_questions'           },
    { model: 'Data::SettingPassRate',           folder: 'summativequiz',    file: 'setting_pass_rate'             },
    { model: 'Data::RolePassRate',              folder: 'summativequiz',    file: 'role_pass_rate'                },
    { model: 'Data::UsersNotPassing',           folder: 'summativequiz',    file: 'users_not_passing_per_module'  },
    { model: 'Data::ResitsPerUser',             folder: 'summativequiz',    file: 'resits_per_user'               },
    { model: 'Data::ModulesPerMonth',           folder: 'summativequiz',    file: 'modules_per_month'             },
    { model: 'Data::UserOverview',              folder: 'overview',         file: 'user_overview'                 },
    { model: 'Data::ModuleOverview',            folder: 'overview',         file: 'module_overview'               },
    { model: 'Data::UserModuleOrder',           folder: 'nonlinear',        file: 'user_module_order'             },
    { model: 'Data::UserModuleCompletion',      folder: 'nonlinear',        file: 'user_module_completion'        },
    { model: 'Data::UserModuleCompletionCount', folder: 'nonlinear',        file: 'user_module_completions_count' },
    { model: 'Data::ReturningUsers',            folder: 'nonlinear',        file: 'returning_users'               },
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

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
