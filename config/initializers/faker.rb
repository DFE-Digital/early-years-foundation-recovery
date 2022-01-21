if Rails.env.test? || Rails.env.development?
  # Set faker to GB region so that setting, such as postcode, work as expected
  Faker::Config.locale = "en-GB"
end
