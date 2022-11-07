class ChangeRegistrationCompletedOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.rename :registration_complete, :private_beta_registration_complete
      t.change_default :private_beta_registration_complete, from: nil, to: false
      t.boolean :registration_complete, default: false
    end
  end
end
