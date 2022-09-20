class AddModuleTimeToCompletionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :module_time_to_completion, :jsonb, default: {}, null: false
  end
end
