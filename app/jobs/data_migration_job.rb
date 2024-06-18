class DataMigrationJob < ApplicationJob
  def run
    require 'migrate_training'
    MigrateTraining.new.call
  end
end
