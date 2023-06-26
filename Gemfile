source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

# Trivy vulnerability warnings:
gem 'time', '>= 0.2.2' # https://avd.aquasec.com/nvd/cve-2023-28756
gem 'uri', '>= 0.12.1' # https://avd.aquasec.com/nvd/cve-2023-28755

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'

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
gem 'slim-rails'

# Headless CMS
gem 'contentful_rails'

# Create models from static data such as hashes or YAML
gem 'active_hash'

# TODO: add ey-recovery to https://github.com/DFE-Digital/govuk-components
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'

# Markdown support
gem 'govspeak'
gem 'sassc' # govspeak assets

gem 'govuk_notify_rails'

# Sentry -Monitor errors
gem 'sentry-rails'
gem 'sentry-ruby'

# Validate and normalise user postcodes
gem 'uk_postcode'

# Manage seeds
gem 'dibber'

# Track users
gem 'ahoy_matey'

# PDF generator middleware
gem 'grover'

# Pa11y accessibility testing
gem 'sitemap_generator'

# Data dashboard feed
gem 'google-cloud-storage'

# Background Jobs
gem 'que-scheduler'

# DRY-RB
gem 'dry-core'
gem 'dry-initializer'
gem 'dry-struct'
gem 'dry-types'

group :development, :test do
  # Use fake data for specs
  gem 'dotenv-rails'
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
  gem 'brakeman'
  gem 'pry-doc'
  gem 'rails-erd'
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
  gem 'cuprite'
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
