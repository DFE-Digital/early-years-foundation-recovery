module Users
  class SettingForm < BaseForm
    attr_accessor :setting_type_id

    validates :setting_type_id, presence: true

    def name
      'setting_types'
    end

    def save
      if valid?
        user.update!(
          setting_type_id: setting_type_id,
          setting_type: SettingType.find(setting_type_id).name,
        )
      end
    end
  end
end
