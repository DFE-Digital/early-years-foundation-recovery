class CreateQueSchedulerSchema < ActiveRecord::Migration[7.0]
  def change
    Que::Scheduler::Migrations.migrate!(version: 7)
  end
end
