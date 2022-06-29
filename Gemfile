source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '>= 7.0.2.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.6'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'cssbundling-rails'
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# User authentication
gem 'devise'

# HTML abstraction markup language
gem 'slim-rails', '~> 3.4', '>= 3.4.0'

# Create models from static data such as hashes or YAML
gem 'active_hash'

# TODO: add ey-recovery to https://github.com/DFE-Digital/govuk-components
gem 'govuk-components', '>= 3.0.3'
gem 'govuk_design_system_formbuilder'

# Markdown support
gem 'govspeak', '~> 6.8', '>= 6.8.2'
gem 'sassc', '~> 2.4' # govspeak assets

gem 'govuk_notify_rails', '~> 2.2', '>= 2.2.0'

# Sentry -Monitor errors
gem 'sentry-rails'
gem 'sentry-ruby'

# Validate and normalise user postcodes
gem 'uk_postcode'

# Manage seeds
gem 'dibber'

# Track users
gem 'ahoy_matey', '~> 4.0'

group :development, :test do
  # Use fake data for specs
  gem 'dotenv-rails', '~> 2.7', '>= 2.7.6'
  gem 'faker'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop-govuk', require: false
  gem 'rubocop-performance', require: false

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  gem 'launchy'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'redcarpet' # code syntax in Yardoc
  gem 'web-console'
  gem 'yard-junk'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'show_me_the_cookies'
  gem 'simplecov'
end

# NB:
# This gem group is being installed into an as yet unused Docker target 'ui' that
# adds additional test dependencies for /ui tests alongside application code.
# However, this is also available in an isolated container, target 'qa'.
#
group :ui do
  gem 'dry-inflector'
  gem 'selenium-webdriver'
  gem 'site_prism'
end
