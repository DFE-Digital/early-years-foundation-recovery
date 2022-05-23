class PasswordValidator < ActiveModel::Validator
  PASSWORD_FORMAT = /\A
    (?=.*\d)    # a number
    (?=.*[a-z]) # a lower case letter
    (?=.*[A-Z]) # an upper case letter
  /x
  # (?=.{8,})   # 8 or more characters

  def validate(record)
    return if record.password.blank? || record.password =~ PASSWORD_FORMAT

    record.errors.add :password,
                      I18n.t('activerecord.errors.models.user.attributes.password.invalid')
  end
end
