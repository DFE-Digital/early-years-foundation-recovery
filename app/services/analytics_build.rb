class AnalyticsBuild
  require 'csv'
  require 'google/cloud/storage'

  attr_accessor :bucket_name, :folder_path, :result_set, :file_name, :gcs

  # @param bucket_name [String] Google bucket name
  # @param folder_path [String] Google bucket folder path
  # @param result_set [ActiveRecord] Active record result set
  # @param file_name [String] File name to create a file on google clound storage
  # @param json_property_name [String] Name of the field which contain's json string

  def initialize(bucket_name:, folder_path:, result_set:, file_name:)
    @bucket_name = bucket_name
    @folder_path = folder_path
    @result_set = result_set
    @file_name = file_name
    @gcs = CloudStorage.new.gcs
  end

  # serializable_hash #{@records<ActiveRecord>} to help with converting json string and appending the json string property in <ActiveRecord>
  # @param results [ActiveRecord] Active record result set
  # @return [Hash<ActiveRecord>]
  def serialize(results)
    results.to_a.map(&:serializable_hash)
  end

  # Create CSV file and save to local Folder, containing #{results} param data
  # @param results [ActiveRecord] Active record result set
  # @return [String] Created file name
  def build(results)
    results = serialize(results)
    file_path = Rails.root.join("analytics_files/#{@file_name}#{Time.zone.now.iso8601}.csv")
    CSV.open(file_path, 'wb') do |csv|
      csv << results.first.keys
      results.each do |event|
        csv << event.values
      end
    end
    Rails.logger.debug file_path
  end

  # Generate CSV string containing #{results} param data
  # @param results [ActiveRecord] Active record result set
  # @return [String]
  def stream(results)
    results = serialize(results)
    CSV.generate do |csv|
      csv << results.first.keys
      results.each do |event|
        csv << event.values
      end
    end
  end

  # Stream data to Google storage to create CSV files within @folder_path
  # @return [String]
  def upload
    bucket = @gcs.bucket @bucket_name, skip_lookup: true
    @result_set.in_batches(of: 5000) do |results|
      file = bucket.create_file StringIO.new(stream(results)), "#{@folder_path}/#{@file_name}#{Time.zone.now.iso8601}.csv"
      Rails.logger.debug file.name
    end
  end

  # Create a local copy of the csv file
  # @return [void]
  def create
    @result_set.in_batches(of: 5000) do |results|
      build(results)
    end
  end

  # Delete all CSV files within @folder_path
  # @return [void]
  def delete_files
    bucket = @gcs.bucket @bucket_name, skip_lookup: true
    files = bucket.files prefix: @folder_path
    files.each(&:delete)
  end

  # convert hyphen to underscore
  # @param key [String|Array|Hash]
  # @return [String]
  def self.transform_json_key(key)
     key.to_s.tr('-', '_')
  end

  # Create a sql query from json object keys 
  # @param column_name [String]
  # @param json_column [Object]
  # @return [String]
  def self.build_json_sql(column_name, json_column)
      sql_array = []
      json_column.keys.map do |key|
        key_name = AnalyticsBuild::change_id(column_name, key)
        sql_array.push("COALESCE(#{column_name}->>'#{key}', 'null') AS #{AnalyticsBuild::transform_json_key(key_name)},")
      end

      sql_array.join()
  end

  # Avoid conflict with table id we rename any id the in json object key
  # @param column_name [String]
  # @param json_column [Object]
  # @return [String]
  def self.change_id(column_name, key)
    if key == 'id'
      return "#{column_name}_#{key}"
    else
      return key
    end
  end
end
