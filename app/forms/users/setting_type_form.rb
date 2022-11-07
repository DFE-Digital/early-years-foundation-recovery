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
        object = SettingType.find(setting_type_id)
        update_attributes = {
          setting_type_id: setting_type_id,
          setting_type: object.name,
        }
        update_attributes.merge!(local_authority: nil) unless setting_type.local_authority_next?
        update_attributes.merge!(role_type: nil) unless setting_type.role_type_next?
        user.update(update_attributes)
        user.save!(validate: false)
      end
    end
  end
end
