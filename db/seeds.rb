# Seed data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
Seeder = Dibber::Seeder

Seeder.seed(:user, name_method: :email) if Rails.application.credentials.user_seed_password.present?

puts Seeder.report # rubocop:disable Rails/Output
