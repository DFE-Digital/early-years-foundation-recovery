# A valid UK postcode is mandatory
#
class PostcodeValidator < ActiveModel::Validator
  def validate(record)
    return if record.postcode.nil?

    record.errors.add :postcode unless UKPostcode.parse(record.postcode).full_valid?
  end
end
