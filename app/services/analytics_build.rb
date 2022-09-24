class AnalyticsBuild
  require 'csv'
  require 'google/cloud/storage'

  attr_accessor :bucket_name, :column_names, :folder_path, :result_set, :file_name, :json_property_name, :gcs

  # @param bucket_name [String] Google bucket name
  # @param folder_path [String] Google bucket folder path
  # @param result_set [ActiveRecord] Active record result set
  # @param file_name [String] File name to create a file on google clound storage
  # @param json_property_name [String] Name of the field which contain's json string

  def initialize(bucket_name:, folder_path:, result_set:, file_name:, json_property_name: nil)
    @column_names = []
    @bucket_name = bucket_name
    @folder_path = folder_path
    @result_set = result_set
    @file_name = file_name
    @json_property_name = json_property_name
    @gcs = CloudStorage.new.gcs
  end

  # serializable_hash #{@records<ActiveRecord>} to help with converting json string and appending the json string property in <ActiveRecord>
  # @param results [ActiveRecord] Active record result set
  # @return [Hash<ActiveRecord>]
  def serialize(results)
    results.to_a.map(&:serializable_hash)
  end

  # Converts @json_property_name within #{@records<ActiveRecord>} into a hash and appends to #{@records<ActiveRecord>}
  # @param records [ActiveRecord] Active record result set
  # @return [Hash<ActiveRecord>]
  def json_to_hash(records)
    records.map do |record|
      unless @json_property_name.nil?
        updated_key_name = record[@json_property_name].transform_keys { |key| key.to_s.tr('-', '_') }

        record.merge!(updated_key_name)
        # we delete this as its not required to be added to the csv file.
        record.delete(@json_property_name)
      end
      # Concat all keys names so we can add json module_time_to_completion dynamically.
      @column_names.concat(record.keys)
    end
    records
  end

  # Create CSV file and save to local Folder, containing #{results} param data
  # @param results [ActiveRecord] Active record result set
  # @return [String] Created file name
  def build(results)
    results = json_to_hash(serialize(results))
    file_path = Rails.root.join("analytics_files/#{@file_name}#{Time.zone.now.iso8601}.csv")
    CSV.open(file_path, 'wb') do |csv|
      csv << @column_names.uniq
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
    results = json_to_hash(serialize(results))
    CSV.generate do |csv|
      csv << @column_names.uniq
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
end
