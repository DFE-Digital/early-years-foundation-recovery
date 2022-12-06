# frozen_string_literal: true

class CloudStorage
  require 'google/cloud/storage'

  def gcs
    google_credentials = JSON.parse(ENV['GOOGLE_CLOUD_STORAGE'])
    @gcs ||= Google::Cloud::Storage.new project: google_credentials['project_id'], credentials: google_credentials
  end
end
