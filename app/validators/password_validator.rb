class PasswordValidator < ActiveModel::Validator
  def validate(record)
    return if record.password.nil?

    # Validates upper and lower case letters, a number and at least 8 characters.
    unless record.password.match? %r{^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$}i
      record.errors.add :password, 'Password does not match the set criteria'
    end
  end
end
