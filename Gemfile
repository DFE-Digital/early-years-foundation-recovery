source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", ">= 7.0.2.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# User authentication
gem "devise"

# HTML abstraction markup language
gem "haml-rails", "~> 2.0", ">= 2.0.1"

# Create models from static data such as hashes or YAML
gem 'active_hash'

gem "govuk-components", ">= 3.0.3"
gem "govuk_design_system_formbuilder"

gem "kramdown", "~> 2.3"      # Markdown support

group :development, :test do
  # Use fake data for specs
  gem "faker"

  gem "foreman"

  gem "dotenv-rails", "~> 2.7", ">= 2.7.6"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
end

gem "govuk_notify_rails", "~> 2.2", ">= 2.2.0"

group :ui_auto do
  gem 'capybara'
  gem 'pry'
  gem 'rspec'
  gem 'rubocop'
  gem 'selenium-webdriver'
  gem 'site_prism'
end
