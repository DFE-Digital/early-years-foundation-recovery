class CreateConfidenceCheckProgress < ActiveRecord::Migration[7.2]
  def change
    create_table :confidence_check_progress do |t|
      t.references :user, foreign_key: true, null: false
      t.string :module_name, null: false
      t.string :check_type, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :skipped_at
      t.timestamps
    end

    # Each user may only have one pre-check and one post-check record per module.
    # This ensures idempotent upserts via find_or_initialize_by in the model.
    add_index :confidence_check_progress, %i[user_id module_name check_type],
              unique: true, name: 'index_confidence_check_on_user_module_type'
  end
end
