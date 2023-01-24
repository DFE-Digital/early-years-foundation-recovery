# Seed data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Dibber::Seeder.seed(:user, name_method: :email) unless Rails.env.test?

Rails.logger.debug Dibber::Seeder.report
