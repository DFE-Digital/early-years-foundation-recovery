class AddTermsAndConditionsAgreedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :terms_and_conditions_agreed_at, :datetime
  end
end
