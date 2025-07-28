module Registration
  class SettingTypeOtherForm < BaseForm
    attr_accessor :setting_type_other

    validates :setting_type_other, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(
        setting_type: 'other',
        setting_type_id: 'other',
        setting_type_other: setting_type_other,
        local_authority: I18n.t(:na),
      )
    end
  end
end
