class CreateQueSchedulerSchema < ActiveRecord::Migration[6.0]
  def change
    Que::Scheduler::Migrations.migrate!(version: 7)
  end

  # def up
  #   Que::Scheduler::Migrations.migrate!(version: 7)
  # end

  # def down
  #   Que::Scheduler::Migrations.migrate!(version: 0)
  # end
end
