class RemoveAhoyNamespace < ActiveRecord::Migration[7.0]
  def change
    rename_table :ahoy_events, :events
    rename_table :ahoy_visits, :visits
  end
end
