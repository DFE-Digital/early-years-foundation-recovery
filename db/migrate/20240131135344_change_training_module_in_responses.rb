class ChangeTrainingModuleInResponses < ActiveRecord::Migration[7.0]
  def change
    change_column_null :responses, :training_module, true
  end
end
