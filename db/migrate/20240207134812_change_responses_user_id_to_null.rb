class ChangeResponsesUserIdToNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :responses, :user_id, true
  end
end
