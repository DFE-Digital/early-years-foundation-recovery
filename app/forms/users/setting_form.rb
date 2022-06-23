module Users
  class SettingForm < BaseForm
    attr_accessor :postcode, :ofsted_number, :setting_type, :setting_type_other

    validates :ofsted_number, ofsted_number: true
    validates :postcode, presence: true, postcode: true
    validates :setting_type, presence: true

    def save
      if valid?
        user.update!(
          postcode: postcode,
          ofsted_number: ofsted_number,
          setting_type: setting_type,
          setting_type_other: setting_type_other,
        )
      end
    end
  end
end
