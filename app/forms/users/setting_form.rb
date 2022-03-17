module Users
  class SettingForm < BaseForm
    attr_accessor :postcode, :ofsted_number

    validates :postcode, presence: true

    def save
      user.update(postcode:, ofsted_number:) if valid?
    end
  end
end
