# A valid UK postcode is mandatory
#
class PostcodeValidator < ActiveModel::Validator
  def validate(record)
    return if record.postcode.nil?

    unless UKPostcode.parse(record.postcode).full_valid?
      record.errors.add :postcode,
                        I18n.t('activerecord.errors.models.user.attributes.postcode.invalid')
    end
  end
end
