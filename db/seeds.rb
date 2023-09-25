Dibber::Seeder.seed(:user, name_method: :email) unless Rails.env.test?

Rails.logger.debug Dibber::Seeder.report
