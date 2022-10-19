module Users
  class SettingTypeOtherForm < BaseForm
    attr_accessor :setting_type_other

    validates :setting_type_other, presence: true

    def name
      'setting_type_others'
    end

    def save
      if valid?
        user.update!(
          setting_type: 'other',
          setting_type_other: setting_type_other,
        )
      end
    end
  end
end
