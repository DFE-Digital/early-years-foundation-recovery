module Registration
  class SettingTypeForm < BaseForm
    validates :setting_type_id, presence: true

    validates :setting_type_id,
              inclusion: { in: Trainee::Setting.valid_types }

    # @return [Boolean]
    def save
      return false unless valid?

      user.update(setting.form_params)
      user.save(validate: false)
    end

  private

    # @return [Trainee::Setting]
    def setting
      Trainee::Setting.by_name(setting_type_id)
    end
  end
end
