# This might start with EY, VC followed by 6 numbers,
# or it might be a 6 or 7 digit number.
#
class OfstedNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.ofsted_number.blank?

    record.errors.add :ofsted_number unless record.ofsted_number.match? %r{\A((ey|vc)\d{6}|\d{6,7})\z}i
  end
end
