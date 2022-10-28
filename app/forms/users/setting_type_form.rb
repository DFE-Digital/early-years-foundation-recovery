module Users
  class SettingTypeForm < BaseForm
    attr_accessor :setting_type_id

    validates :setting_type_id, presence: true

    validates :setting_type_id,
              inclusion: { in: SettingType.all.map(&:id).push('other') }

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
