# Seed data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
Seeder = Dibber::Seeder

Seeder.seed(:user, name_method: :email)

Rails.logger.debug Seeder.report
