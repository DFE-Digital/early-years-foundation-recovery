module Users
  class SettingForm < BaseForm
    attr_accessor :setting_type

    validates :setting_type, presence: true

    def name
      'setting_types'
    end

    def save
      if valid?
        user.update!(
          setting_type: setting_type,
        )
      end
    end
  end
end
