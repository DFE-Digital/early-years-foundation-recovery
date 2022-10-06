# frozen_string_literal: true

class CloudStorage
  require 'google/cloud/storage'
  attr_accessor :gcs

  def initialize
    
    # @gcs = Google::Cloud::Storage.new project: project_id, credentials: JSON.parse(ENV['GOOGLE_CLOUD_STORAGE'])
  end

  def gcs
    project_id = ENV['GOOGLE_CLOUD_PROJECT_ID']
    @gcs ||= Google::Cloud::Storage.new project: project_id, credentials: JSON.parse(ENV['GOOGLE_CLOUD_STORAGE'])
  end
end
