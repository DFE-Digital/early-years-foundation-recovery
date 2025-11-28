module Registration
  class SettingTypeForm < BaseForm
    validates :setting_type_id, presence: true

    validate :setting_type_is_valid

    # @return [Boolean]
    def save
      return false unless valid?

      # Clear fields *before* calling update with form_params
      user.update(setting.form_params)
      user.save(validate: false)
    end

  private

    # @return [void]
    def setting_type_is_valid
      return if setting_type_id.blank?
      return if Trainee::Setting.valid_types.include?(setting_type_id)
      return if user&.setting_type_id == setting_type_id

      errors.add(:setting_type_id, :inclusion)
    end

    # @return [Trainee::Setting]
    def setting
      Trainee::Setting.by_name(setting_type_id)
    end
  end
end
