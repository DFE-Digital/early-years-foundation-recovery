# This might start with EY, VC followed by 6 numbers, or it might be an 8 letter number.
# @see locale: extra_registration.setting.ofsted_hint
#
class OfstedNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.ofsted_number.blank?

    unless record.ofsted_number.match? %r{\A((ey|vc)\d{6}|\d{8})\z}i
      record.errors.add :ofsted_number,
                        I18n.t('activerecord.errors.models.user.attributes.ofsted_number.invalid')
    end
  end
end
