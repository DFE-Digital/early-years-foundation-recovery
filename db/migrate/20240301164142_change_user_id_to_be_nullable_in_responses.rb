class ChangeUserIdToBeNullableInResponses < ActiveRecord::Migration[7.1]
  def change
    change_column_null :responses, :user_id, true
  end
end
