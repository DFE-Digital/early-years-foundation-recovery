class DataMigrationJob < ApplicationJob
  def run
    require 'migrate_training'
    super do
      MigrateTraining.new.call
    end
  end
end
