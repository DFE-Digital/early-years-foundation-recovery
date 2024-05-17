class UpdateQueSchedulerSchema < ActiveRecord::Migration[7.1]
  def change
    Que::Scheduler::Migrations.migrate!(version: 8)
  end
end
