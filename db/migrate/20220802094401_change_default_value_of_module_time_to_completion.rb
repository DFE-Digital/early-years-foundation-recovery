class ChangeDefaultValueOfModuleTimeToCompletion < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :module_time_to_completion, from: 0, to: {}
  end
end
